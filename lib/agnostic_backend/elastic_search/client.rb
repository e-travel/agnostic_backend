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
        @connection = connection(endpoint)
      end

      def connection(endpoint)
        ::Faraday::Connection.new(url: endpoint)
      end

      def get(id)
        perform_request("get", "#{index_type_path}/#{id}", nil, nil)
      end

      def upload_document(document, id = nil)
        method = id.present? ? "put" : "post"
        response = perform_request(method, "#{@index_type_path}/#{id}", nil, document)
        MultiJson.load(response.body)["created"]
      end

      def define_index_field(endpoint:, index_name:, type:, definition:)
        response = perform_request("put", "#{index_name}/_mapping/#{type}", nil, {"properties" => definition})
        MultiJson.load(response.body)["acknowledged"]
      end

      def perform_request(method, path, params, body)
        @connection.run_request(method.downcase.to_sym, 
                               path, 
                               ( body ? MultiJson.dump(body): nil ), 
                               {'Content-Type' => 'application/json'})
      end

     
    end
  end
end