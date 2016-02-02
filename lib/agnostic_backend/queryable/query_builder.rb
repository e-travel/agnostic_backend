module AgnosticBackend
  module Queryable
    class QueryBuilder

      attr_reader :index
      attr_reader :query

      def initialize(index)
        @index = index
      end

      def criteria_builder
        CriteriaBuilder.new(self)
      end

      def where(criteria)
        @criteria = criteria
        self
      end

      def select(*attributes)
        (@projections ||= []).push(*attributes)
        self
      end

      def order(attribute, direction)
        (@order_qualifiers ||= []).push build_order_qualifier(attribute, direction)
        self
      end

      def limit(value)
        @limit = value
        self
      end

      def offset(value)
        @offset = value
        self
      end

      def build
        query = create_query(self)
        query.children << build_where_expression if @criteria
        query.children << build_select_expression if @projections
        query.children << build_order_expression if @order_qualifiers
        query.children << build_limit_expression if @limit
        query.children << build_offset_expression if @offset

        @query = query
      end

      private

      def create_query(context)
        raise NotImplementedError, 'AbstractMethod'
      end

      def build_where_expression
        Expressions::Where.new(@criteria, self)
      end

      def build_select_expression
        Expressions::Select.new(@projections, self)
      end

      def build_order_expression
        Expressions::Order.new(@order_qualifiers, self)
      end

      def build_limit_expression
        Expressions::Limit.new(@limit, self)
      end

      def build_offset_expression
        Expressions::Offset.new(@offset, self)
      end

      def build_order_qualifier(attribute, direction)
        case direction
          when :asc
            Operations::Ascending.new(attribute, self)
          when :desc
            Operations::Descending.new(attribute, self)
        end
      end
    end
  end
end
