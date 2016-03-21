module AgnosticBackend
  module ElasticSearch
    class Index < AgnosticBackend::Index
      def initialize(indexable_klass, **options)
        super(indexable_klass)
      end

      def indexer
        AgnosticBackend::ElasticSearch::Indexer.new(self)
      end

      def query_builder
        raise "Json Implement Me"
      end

      # ?
      def schema
        @schema ||= @indexable_klass.schema { |ftype| ftype }
      end

      def elastic_search_client
        @client = AgnosticBackend::ElasticSearch::Client.new
      end
    end
  end
end
