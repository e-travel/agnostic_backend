module AgnosticBackend
  module Elasticsearch
    class Index < AgnosticBackend::Index

      attr_reader :index_name,
                  :type,
                  :endpoint
      
      def initialize(indexable_klass, **options)
        super(indexable_klass)
        @index_name = parse_option(options, :index_name)
        @type = parse_option(options, :type)
        @endpoint = parse_option(options, :endpoint)
      end

      def indexer      
        AgnosticBackend::Elasticsearch::Indexer.new(self)
      end

      def query_builder
        raise "Json Implement Me"
      end

      def schema
        @schema ||= @indexable_klass.schema { |ftype| ftype }
      end

      def elasticsearch_client
        @elasticsearch_client ||= AgnosticBackend::Elasticsearch::Client.new(endpoint: endpoint)
      end

      def create_index
        elasticsearch_client.put(path: index_name)
      end

      def configure
        define_mappings(indexer.flatten(schema))
      end

      private
      
      def define_mappings(flat_schema)
        index_fields(flat_schema).each do |index_field|
          elasticsearch_client.put(
            path: index_mapping_type_path, 
            body: { "properties" => index_field.definition })
        end
      end

      def index_fields(flat_schema)
        flat_schema.map do |field_name, field_type|
          AgnosticBackend::Elasticsearch::IndexField.new(field_name, field_type)
        end
      end

      def index_mapping_type_path
        "#{index_name}/_mapping/#{type}"
      end
    end
  end
end
