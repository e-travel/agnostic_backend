module AgnosticBackend
  module Cloudsearch
    class Index < AgnosticBackend::Index

      attr_reader :region,
                  :domain_name,
                  :document_endpoint,
                  :search_endpoint,
                  :access_key_id,
                  :secret_access_key

      def indexer
        AgnosticBackend::Cloudsearch::Indexer.new(self)
      end

      def query_builder
        AgnosticBackend::Queryable::Cloudsearch::QueryBuilder.new(self)
      end

      def schema
        @schema ||= @indexable_klass.schema{|ftype| ftype}
      end

      def configure
        define_fields_in_domain(indexer.flatten(schema))
      end

      def cloudsearch_client
        @cloudsearch_client ||= Aws::CloudSearch::Client.new(region: region, access_key_id: access_key_id, secret_access_key: secret_access_key)
      end

      def cloudsearch_domain_client
        @cloudsearch_domain_client ||= Aws::CloudSearchDomain::Client.new(endpoint: search_endpoint, access_key_id: access_key_id, secret_access_key: secret_access_key)
      end

      private

      def remove_fields_from_domain(remote_fields, verbose: true)
        remote_fields.map(&:index_field_name).each do |field_name|
          puts "#{domain_name} > Removing obsolete field: #{field_name}" if verbose
          cloudsearch_client.delete_index_field(domain_name: domain_name,
                                                index_field_name: field_name)
        end
      end

      def define_fields_in_domain(flat_schema, verbose: true)
        remote_fields = cloudsearch_client.describe_index_fields(domain_name: domain_name).
                         index_fields.map{|field| RemoteIndexField.new(field)}
        puts "Found #{remote_fields.size} remote fields in #{domain_name}" if verbose
        local_fields = index_fields(flat_schema)
        puts "Found #{local_fields.size} local fields for that domain" if verbose

        valid_remote_fields, obsolete_remote_fields =
          RemoteIndexField.partition(local_fields, remote_fields)
        puts "Found #{valid_remote_fields.size} valid remote fields" if verbose
        puts "Found #{obsolete_remote_fields.size} obsolete remote fields" if verbose

        remove_fields_from_domain(obsolete_remote_fields) unless obsolete_remote_fields.empty?

        local_fields.each do |index_field|
          # find the corresponding remote field
          remote_field = valid_remote_fields.find do |remote_field|
            remote_field.index_field_name == index_field.name
          end
          if remote_field.nil? ||
             (remote_field.present? && !index_field.equal_to_remote_field?(remote_field))
            puts "#{domain_name} > Defining new field: #{index_field.name}" if verbose
            index_field.define_in_domain(index: self)
          end
        end
        nil
      end

      def index_fields(flat_schema)
        flat_schema.map do |field_name, field_type|
          AgnosticBackend::Cloudsearch::IndexField.new(field_name, field_type)
        end
      end

      def parse_options
        @region = parse_option(:region)
        @domain_name = parse_option(:domain_name)
        @document_endpoint = parse_option(:document_endpoint)
        @search_endpoint = parse_option(:search_endpoint)
        @access_key_id = parse_option(:access_key_id)
        @secret_access_key = parse_option(:secret_access_key)
      end

    end
  end
end
