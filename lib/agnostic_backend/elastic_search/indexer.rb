  module AgnosticBackend
  module Elasticsearch
    class Indexer < AgnosticBackend::Indexer
      include AgnosticBackend::Utilities
      
      def initialize(index)
        super
      end

      def publish(document)
        client.upload_document(document, id = document[:id].to_s)
      end

      def get(id)
        client.get(id)
      end

      private
      def client
        index.elastic_search_client
      end

      def prepare(document)
        document
      end

      def transform(document)
        document
      end
    end
  end
end
