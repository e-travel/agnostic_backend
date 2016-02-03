require 'aws-sdk'

module AgnosticBackend
  module Cloudsearch
    class Indexer < AgnosticBackend::Indexer
      include AgnosticBackend::Utilities

      def initialize(index)
        @index = index
      end

      def publish(document)
        with_exponential_backoff Aws::CloudSearch::Errors::Throttling do
          client.upload_documents(
            documents: document,
            content_type:'application/json'
          )
        end
      end

      def delete(*document_ids)
        documents = document_ids.map do |document_id|
          {"type" => 'delete',
           "id" => document_id}
        end

        with_exponential_backoff Aws::CloudSearch::Errors::Throttling do
          client.upload_documents(
            documents: convert_to_json(documents),
            content_type:'application/json'

          )
        end
      end

      private

      def client
        index.cloudsearch_domain_client
      end

      def prepare(document)
        document
      end

      def transform(document)
        return {} if document.empty?

        document = flatten document
        document = reject_blank_values_from document
        document = convert_bool_values_to_string_in document
        document = date_format document
        document = add_metadata_to document
        document = convert_document_into_array(document)
        convert_to_json document

      end

      def date_format(document)
        document.each do |k, v|
          if v.is_a?(Time)
            document[k] = v.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
          end
        end
      end

      def add_metadata_to(document)
        {
            "type" => "add",
            "id" => document["id"].to_s,
            "fields" => document,
        }
      end

      def convert_to_json(transformed_document)
        ActiveSupport::JSON.encode(transformed_document)
      end

      def convert_document_into_array(document)
        [document]
      end
    end
  end
end
