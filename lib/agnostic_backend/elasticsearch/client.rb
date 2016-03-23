require 'faraday'

module AgnosticBackend
  module Elasticsearch
    class Client
      attr_reader :endpoint

      def initialize(endpoint:)
        @endpoint = endpoint
        @connection = ::Faraday::Connection.new(url: endpoint)
      end
      
      # Alias methods to make an HTTP method call to remote ES endpoint
      # @param [Hash] a Hash containg all the required 
      # key-value pairs to make a request: { path:, params:, body: }
      # path: URI path
      # params: any URI query parameters TODO: NOT IMPLEMENTED
      # body: any POST / PUT payload
      # @returns [Faraday] instance
      [:post, :put, :delete, :head].each do |method_name|
        define_method(method_name) do |*args|
          perform_request(method_name, *args)
        end
      end

      private 
      def perform_request(method, path: "", params: nil, body: nil)
        @connection.run_request(method.downcase.to_sym, 
                                path, 
                                ( body ? ActiveSupport::JSON.encode(body): nil ), 
                                {'Content-Type' => 'application/json'})
      end
    end
  end
end
