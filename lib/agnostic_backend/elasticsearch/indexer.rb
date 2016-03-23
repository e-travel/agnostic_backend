module AgnosticBackend
  module Elasticsearch
    class Indexer < AgnosticBackend::Indexer
      include AgnosticBackend::Utilities

      def initialize(index)
        super
      end

      def publish(document)
        client.upload_document(document)
      end

      private

      def client
        index.elasticsearch_client
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
