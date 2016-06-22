module AgnosticBackend
  module Queryable
    module Elasticsearch
      class Executor < AgnosticBackend::Queryable::Executor
        include AgnosticBackend::Utilities

        def execute
          if scroll_cursor.present?
            response = client.send_request(:post, path: "_search/scroll", body: params)
          else 
            response = client.send_request(:post, path: "#{index.index_name}/#{index.type}/_search", body: params)
          end          
          ResultSet.new(ActiveSupport::JSON.decode(response.body), query)
        end

        def to_s
          params
        end

        def params
          scroll_cursor.present? ? scroll_cursor : query.accept(visitor)
        end

        private

        def client
          index.client
        end

        def index
          query.context.index
        end

        def scroll_cursor
          scroll_cursor_expression.accept(visitor) if scroll_cursor_expression
        end
      end
    end
  end
end