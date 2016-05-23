module AgnosticBackend
  module Queryable
    module Elasticsearch
      class Executor < AgnosticBackend::Queryable::Executor
        include AgnosticBackend::Utilities

        def execute          
          response = client.send_request(:post, path: "#{index.index_name}/#{index.type}/_search", body: params)
          ResultSet.new(ActiveSupport::JSON.decode(response.body), query)
        end

        def to_s
          params
        end

        def params
          query.accept(visitor)
        end

        private

        def client
          index.client
        end

        def index
          query.context.index
        end
      end
    end
  end
end