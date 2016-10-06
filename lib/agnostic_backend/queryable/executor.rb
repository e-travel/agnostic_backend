module AgnosticBackend
  module Queryable
    class Executor

      attr_reader :query
      attr_reader :visitor
      attr_reader :options

      def initialize(query, visitor, **options)
        @query = query
        @visitor = visitor
        @options = options
      end

      def execute
        raise NotImplementedError, 'Abstract method'
      end

      private

      def order_expression
        query.children.find { |e| e.is_a? Expressions::Order }
      end

      def where_expression
        query.children.find { |e| e.is_a? Expressions::Where }
      end

      def select_expression
        query.children.find { |e| e.is_a? Expressions::Select }
      end

      def limit_expression
        query.children.find { |e| e.is_a? Expressions::Limit }
      end

      def offset_expression
        query.children.find { |e| e.is_a? Expressions::Offset }
      end

      def scroll_cursor_expression
        query.children.find { |e| e.is_a? Expressions::ScrollCursor }
      end

      def filter_expression
        query.children.find { |e| e.is_a? Expressions::Filter }
      end
    end
  end
end