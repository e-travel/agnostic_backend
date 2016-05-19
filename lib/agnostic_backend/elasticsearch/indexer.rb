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

      def search(body)
        client.post(path: "{index_type_path}/_search", body: body)
      end

      private

      def client
        index.client
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

      def date_format(document)
        document.each do |k, v|
        if v.is_a?(Time)
          document[k] = v.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
        end
      end
    end
    end
  end
end
