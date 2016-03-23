module AgnosticBackend
  module Elasticsearch
    class Indexer < AgnosticBackend::Indexer
      include AgnosticBackend::Utilities

      def initialize(index)
        super
      end

      def publish(document)
        client.put(path: index_type_path(document[:id]), body: document)
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

      def index_type_path(doc_id = nil)
        return "/#{index.index_name}/#{index.type}/#{doc_id}" if doc_id.present?

        "/#{index.index_name}/#{index.type}"
      end
    end
  end
end
