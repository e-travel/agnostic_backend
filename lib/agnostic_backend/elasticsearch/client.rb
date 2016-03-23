require 'faraday'

module AgnosticBackend
  module Elasticsearch
    class Client
      attr_reader :endpoint, 
                  :index_name,
                  :type

      def initialize(endpoint:, index_name:, type:)
        @endpoint = endpoint
        @index_name = index_name
        @type = type
        @connection = new_connection(endpoint)
      end

      def upload_document(document)
        document_id = document[:id]
        method = document_id.present? ? "put" : "post"
        
        response = perform_request(method, index_type_path(document_id), nil, document)
        ActiveSupport::JSON.decode(response.body)["created"]
      end

      def define_mapping(definition:)
        response = perform_request("put", index_mapping_type_path, nil, { "properties" => definition })
        ActiveSupport::JSON.decode(response.body)["acknowledged"]
      end

      private 

      def perform_request(method, path, params, body)
        @connection.run_request(method.downcase.to_sym, 
                                path, 
                                ( body ? ActiveSupport::JSON.encode(body): nil ), 
                                {'Content-Type' => 'application/json'})
      end

      def index_type_path(doc_id = nil)
        return "/#{index_name}/#{type}/#{doc_id}" if doc_id.present?

        "/#{index_name}/#{type}"
      end
      
      def index_mapping_type_path
        "#{index_name}/_mapping/#{type}"
      end

      def new_connection(endpoint)
        ::Faraday::Connection.new(url: endpoint)
      end  
    end
  end
end
