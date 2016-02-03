require 'aws-sdk'

module AgnosticBackend
  module Queryable
    module Cloudsearch
      class Executor < AgnosticBackend::Queryable::Executor
        include AgnosticBackend::Utilities

        def execute
          with_exponential_backoff Aws::CloudSearch::Errors::Throttling do
            response = client.search(params)
            ResultSet.new(response, query)
          end
        end

        def to_s
          result = ''
          result += "search?q=#{query_expression}" if query_expression
          result += " return=#{return_expression}" if return_expression
          result += " sort=#{sort}" if sort
          result += " size=#{size}" if size
          result += " offset=#{start}" if start
          result += " cursor=#{cursor}" if cursor
          result
        end

        def params
          {
            cursor: cursor,
            expr: expr,
            facet: facet,
            filter_query: filter_query,
            highlight: highlight,
            partial: partial,
            query: query_expression,
            query_options: query_options,
            query_parser: query_parser,
            return: return_expression,
            size: size,
            sort: sort,
            start: start
          }
        end

        private

        def client
          query.base.index.cloudsearch_domain_client
        end

        def filter_query
        end

        def cursor_expression
          query.children.find { |e| e.is_a? AgnosticBackend::Queryable::Cloudsearch::Expressions::Cursor }
        end

        def query_expression
          where_expression ? where_expression.accept(visitor) : 'matchall'
        end

        def cursor
          cursor_expression.accept(visitor) if cursor_expression
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