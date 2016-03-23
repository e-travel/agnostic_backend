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
        @elasticsearch_client ||= AgnosticBackend::Elasticsearch::Client.new(endpoint: endpoint, index_name: index_name, type: type)
      end

      def configure
        define_mappings(indexer.flatten(schema))
      end

      private
      def define_mappings(flat_schema)
        local_fields = index_fields(flat_schema)

        local_fields.each do |index_field|
          elasticsearch_client.define_mapping(definition: index_field.definition)
        end
      end

      def index_fields(flat_schema)
        flat_schema.map do |field_name, field_type|
          AgnosticBackend::Elasticsearch::IndexField.new(field_name, field_type)
        end
      end
    end
  end
end
