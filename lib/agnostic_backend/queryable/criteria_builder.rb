module AgnosticBackend
  module Queryable
    class CriteriaBuilder

      attr_reader :context

      def initialize(query_builder)
        @context = query_builder
      end

      def eq(attribute, value)
        Criteria::Equal.new(attribute: attribute, value: value, context: context)
      end

      def neq(attribute, value)
        Criteria::NotEqual.new(attribute: attribute, value: value, context: context)
      end

      def gt(attribute, value)
        Criteria::Greater.new(attribute: attribute, value: value, context: context)
      end

      def lt(attribute, value)
        Criteria::Less.new(attribute: attribute, value: value, context: context)
      end

      def ge(attribute, value)
        Criteria::GreaterEqual.new(attribute: attribute, value: value, context: context)
      end

      def le(attribute, value)
        Criteria::LessEqual.new(attribute: attribute, value: value, context: context)
      end

      def gt_and_lt(attribute, left_limit, right_limit)
        Criteria::GreaterAndLess.new(attribute: attribute, left_value: left_limit, right_value: right_limit, context: context)
      end

      def gt_and_le(attribute, left_limit, right_limit)
        Criteria::GreaterAndLessEqual.new(attribute: attribute, left_value: left_limit, right_value: right_limit, context: context)
      end

      def ge_and_lt(attribute, left_limit, right_limit)
        Criteria::GreaterEqualAndLess.new(attribute: attribute, left_value: left_limit, right_value: right_limit, context: context)
      end

      def ge_and_le(attribute, left_limit, right_limit)
        Criteria::GreaterEqualAndLessEqual.new(attribute: attribute, left_value: left_limit, right_value: right_limit, context: context)
      end

      def contains(attribute, value)
        Criteria::Contains.new(attribute: attribute, value: value, context: context)
      end

      def starts(attribute, value)
        Criteria::Starts.new(attribute: attribute, value: value, context: context)
      end

      def free_text(attribute, value)
        Criteria::FreeText.new(attribute: attribute, value: value, context: context)
      end

      def asc(attribute)
        Operations::Ascending.new(attribute: attribute, context: context)
      end

      def desc(attribute)
        Operations::Descending.new(attribute: attribute, context: context)
      end

      def not(criterion)
        Operations::Not.new(operand: criterion, context: context)
      end

      def and(*criteria)
        Operations::And.new(operands: criteria, context: context)
      end

      def or(*criteria)
        Operations::Or.new(operands: criteria, context: context)
      end

      alias_method :all, :and
      alias_method :any, :or
    end
  end
end
