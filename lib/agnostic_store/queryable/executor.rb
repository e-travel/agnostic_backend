module AgnosticStore
  module Queryable
    class Executor

      attr_reader :query
      attr_reader :visitor

      def initialize(query, visitor)
        @query, @visitor = query, visitor
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
    end
  end
end