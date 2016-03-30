module AgnosticBackend
  module Elasticsearch
    class Indexer < AgnosticBackend::Indexer
      include AgnosticBackend::Utilities

      def initialize(index)
        super
      end

      def publish(document)
        if document["id"].present?
          client.put(path: index_type_path(document["id"]), body: document)
        else
          client.post(path: index_type_path, body: document)
        end
      end

      private

      def client
        index.elasticsearch_client
      end

      def prepare(document)
        document
      end

      def transform(document)
        return {} if document.empty?

        document = flatten document
        document = reject_blank_values_from document
        document = date_format document
        document
      end

      def index_type_path(doc_id = nil)
        return "/#{index.index_name}/#{index.type}/#{doc_id}" if doc_id.present?

        "/#{index.index_name}/#{index.type}"
      end
    end
  end
end
