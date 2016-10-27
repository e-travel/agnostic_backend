require 'aws-sdk'

module AgnosticBackend
  module Cloudsearch

    class PayloadLimitExceededError < StandardError ; end

    class Indexer < AgnosticBackend::Indexer
      include AgnosticBackend::Utilities

      MAX_PAYLOAD_SIZE_IN_BYTES = 4_500_000

      def delete(document_id)
        delete_all([document_id])
      end

      def delete_all(document_ids)
        documents = document_ids.map do |document_id|
          {"type" => 'delete',
           "id" => document_id}
        end
        publish_all(documents)
      end


      def publish(document)
        publish_all([document])
      end

      def publish_all(documents)
        return if documents.empty?
        payload = ActiveSupport::JSON.encode(documents)
        raise PayloadLimitExceededError.new if payload_too_heavy? payload
        with_exponential_backoff Aws::CloudSearch::Errors::Throttling do
          client.upload_documents(
            documents: payload,
            content_type:'application/json'
          )
        end
      end

      private

      def client
        index.cloudsearch_domain_client
      end

      def prepare(document)
        raise IndexingError.new "Document does not have an ID field" unless document["id"].present?
        document
      end

      def transform(document)
        return {} if document.empty?

        document = flatten document
        document = reject_blank_values_from document
        document = convert_bool_values_to_string_in document
        document = date_format document
        document = add_metadata_to document
        document

      end

      def date_format(document)
        document.each do |k, v|
          if v.is_a?(Time)
            document[k] = v.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
          elsif v.is_a?(Array) && v.all?{|e| e.is_a?(Time)}
            document[k] = v.map{|e| e.utc.strftime("%Y-%m-%dT%H:%M:%SZ")}
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

      def payload_too_heavy?(payload)
        payload.bytesize > MAX_PAYLOAD_SIZE_IN_BYTES
      end

    end
  end
end
