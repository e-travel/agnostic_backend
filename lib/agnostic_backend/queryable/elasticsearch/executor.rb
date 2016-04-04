module AgnosticBackend
  module Queryable
    module Elasticsearch
      class Executor < AgnosticBackend::Queryable::Executor
        include AgnosticBackend::Utilities

        def execute
          pp params
          response = indexer.search(params)
          ResultSet.new(response, query)
        end

        def to_s
          result = ''
          result += "search?q=#{query_expression}" if query_expression
          result += " return=#{return_expression}" if return_expression
          result += " sort=#{sort}" if sort
          result += " size=#{size}" if size
          result += " offset=#{start}" if start
          result += " cursor=#{scroll_cursor}" if scroll_cursor
          result
        end

        def params
          result = {}
          result.deep_merge({"query" => query_expression})
        end

        private

        def indexer
          query.context.index.indexer
        end

        def filter_query
        end

        def query_expression
          where_expression ? where_expression.accept(visitor) : {"query" => {"match_all" => {}}}
        end

        def scroll_cursor
          scroll_cursor_expression.accept(visitor) if scroll_cursor_expression
        end

        def start
          offset_expression.accept(visitor) if offset_expression
        end

        def expr
        end

        def facet
        end

        def highlight
        end

        def partial
          false
        end

        def query_options
        end

        def query_parser
          'structured'
        end

        def return_expression
          select_expression.accept(visitor) if select_expression
        end

        def size
          limit_expression.accept(visitor) if limit_expression
        end

        def sort
          order_expression.accept(visitor) if order_expression
        end
      end
    end
  end
end