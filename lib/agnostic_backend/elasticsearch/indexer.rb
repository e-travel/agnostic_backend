module AgnosticBackend
  module Elasticsearch
    class Indexer < AgnosticBackend::Indexer
      include AgnosticBackend::Utilities

      private

      def client
        index.client
      end

      def publish(document)
        client.send_request(:put,
                            path: "/#{index.index_name}/#{index.type}/#{document["id"]}",
                            body: document)
      end

      def publish_all(documents)
        return if documents.empty?
        response = client.send_request(:post,
                                       path: "/#{index.index_name}/#{index.type}/_bulk",
                                       body: convert_to_bulk_upload_string(documents))
        body = ActiveSupport::JSON.decode(response.body) rescue {}
        # if at least one indexing attempt fails, raise the red flag
        raise IndexingError.new, "Error in bulk upload" if body["errors"]
        response
      end


      def prepare(document)
        raise IndexingError.new, "Document does not have an ID field" unless document["id"].present?
        document
      end

      def transform(document)
        return {} if document.empty?

        document = flatten document
        document = reject_blank_values_from document
        document = format_dates_in document
        document
      end

      def format_dates_in(document)
        document.each do |k, v|
          if v.is_a?(Time)
            document[k] = v.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
          end
        end
      end

      def convert_to_bulk_upload_string(documents)
        documents.map do |document|
          next if document.empty?
          header = { "index" => {"_id" => document["id"]}}.to_json
          document = ActiveSupport::JSON.encode transform(prepare(document))
          "#{header}\n#{document}\n"
        end.compact.join("\n")
      end
    end
  end
end
