module AgnosticBackend
  module Elasticsearch
    class Index < AgnosticBackend::Index

      attr_reader :index_name,
                  :type,
                  :endpoint,
                  :enable_all
      # TODO: add authentication of some sort

      def initialize(indexable_klass, **options)
        super(indexable_klass)
        @index_name = parse_option(options, :index_name)
        @type = parse_option(options, :type)
        @endpoint = parse_option(options, :endpoint)
        @enable_all = parse_option(options, :enable_all)
      end

      def indexer
        AgnosticBackend::Elasticsearch::Indexer.new(self)
      end

      def query_builder
        AgnosticBackend::Queryable::Elasticsearch::QueryBuilder.new(self)
      end

      def schema
        @schema ||= @indexable_klass.schema { |ftype| ftype }
      end

      def client
        @client ||= AgnosticBackend::Elasticsearch::Client.new(endpoint: endpoint)
      end

      def configure
        body = mappings(indexer.flatten(schema))
        client.send_request(:put, path: "#{index_name}/_mapping/#{type}", body: body)
      end

      def create
        client.send_request(:put, path: index_name)
      end

      def destroy!
        client.send_request(:delete, path: index_name)
      end

      def exists?
        response = client.send_request(:head, path: index_name)
        response.success?
      end

      private

      def mappings(flat_schema)
        {
          "_all" => { "enabled" => enable_all },
          "properties" => index_fields(flat_schema).map{|field| field.definition}.reduce({}, &:merge)
        }
      end

      def index_fields(flat_schema)
        flat_schema.map do |field_name, field_type|
          AgnosticBackend::Elasticsearch::IndexField.new(field_name, field_type)
        end
      end
    end
  end
end
