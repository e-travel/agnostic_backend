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

      def where(criterion)
        @criterion = criterion
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

      def scroll_cursor(value)
        @scroll_cursor = value
        self
      end

      def filter(filter)
        @filter = filter
        self
      end

      def build(**options)
        query = create_query(self, **options)
        query.children << build_where_expression if @criterion
        query.children << build_select_expression if @projections
        query.children << build_order_expression if @order_qualifiers
        query.children << build_limit_expression if @limit
        query.children << build_offset_expression if @offset
        query.children << build_filter_expression if @filter
        query.children << build_scroll_cursor_expression if @scroll_cursor

        @query = query
      end

      private

      def create_query(context, **options)
        raise NotImplementedError, 'AbstractMethod'
      end

      def build_where_expression
        Expressions::Where.new(criterion: @criterion, context: self)
      end

      def build_filter_expression
        Expressions::Filter.new(criterion: @filter, context: self)
      end

      def build_select_expression
        Expressions::Select.new(attributes: @projections, context: self)
      end

      def build_order_expression
        Expressions::Order.new(attributes: @order_qualifiers, context: self)
      end

      def build_limit_expression
        Expressions::Limit.new(value: @limit, context: self)
      end

      def build_offset_expression
        Expressions::Offset.new(value: @offset, context: self)
      end

      def build_scroll_cursor_expression
        Expressions::ScrollCursor.new(value: @scroll_cursor, context: self)
      end

      def build_order_qualifier(attribute, direction)
        case direction
          when :asc
            Operations::Ascending.new(attribute: attribute, context: self)
          when :desc
            Operations::Descending.new(attribute: attribute, context: self)
        end
      end
    end
  end
end
