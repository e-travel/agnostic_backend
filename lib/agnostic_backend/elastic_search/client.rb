require 'faraday'

module AgnosticBackend
  module ElasticSearch
    class Client
      class NotFoundError < StandardError; end
      class BadRequestError < StandardError; end
      class ServerError < StandardError; end

      CONNECTION = ::Faraday::Connection.new url: 'http://localhost:9200'

      # Relational DB  ⇒ Databases ⇒ Tables ⇒ Rows      ⇒ Columns
      # Elasticsearch  ⇒ Indices   ⇒ Types  ⇒ Documents ⇒ Fields
      def initialize(index="index", type="type")
        @index_type_path = "/#{index}/#{type}"
      end

      def get(id)
        perform_request("get", "#{index_type_path}/#{id}", nil, nil)
      end
  
      # 
      def upload_document(document, id = nil)
        method = id.present? ? "put" : "post"
        response = perform_request(method, "#{@index_type_path}/#{id}", nil, document)
        MultiJson.load(response.body)["created"]
      end

      private
      attr_reader :index_type_path

      def perform_request(method, path, params, body)
        CONNECTION.run_request(method.downcase.to_sym, 
                               path, 
                               ( body ? MultiJson.dump(body): nil ), 
                               {'Content-Type' => 'application/json'})
      end
    end
  end
end
