module AgnosticBackend
  module Queryable
    class CriteriaBuilder

      attr_reader :context

      def initialize(query_builder)
        @context = query_builder
      end

      def eq(attribute, value)
        Criteria::Equal.new([attribute, value], context)
      end

      def neq(attribute, value)
        Criteria::NotEqual.new([attribute, value], context)
      end

      def gt(attribute, value)
        Criteria::Greater.new([attribute, value], context)
      end

      def lt(attribute, value)
        Criteria::Less.new([attribute, value], context)
      end

      def ge(attribute, value)
        Criteria::GreaterEqual.new([attribute, value], context)
      end

      def le(attribute, value)
        Criteria::LessEqual.new([attribute, value], context)
      end

      def gt_and_lt(attribute, left_limit, right_limit)
        Criteria::GreaterAndLess.new([attribute, left_limit, right_limit], context)
      end

      def gt_and_le(attribute, left_limit, right_limit)
        Criteria::GreaterAndLessEqual.new([attribute, left_limit, right_limit], context)
      end

      def ge_and_lt(attribute, left_limit, right_limit)
        Criteria::GreaterEqualAndLess.new([attribute, left_limit, right_limit], context)
      end

      def ge_and_le(attribute, left_limit, right_limit)
        Criteria::GreaterEqualAndLessEqual.new([attribute, left_limit, right_limit], context)
      end

      def contains(attribute, value)
        Criteria::Contain.new([attribute, value], context)
      end

      def starts(attribute, value)
        Criteria::Start.new([attribute, value], context)
      end

      def asc(attribute)
        Operations::Ascending.new([attribute], context)
      end

      def desc(attribute)
        Operations::Descending.new([attribute], context)
      end

      def not(criterion)
        Operations::Not.new([criterion], context)
      end

      def and(*criteria)
        Operations::And.new(criteria, context)
      end

      def or(*criteria)
        Operations::Or.new(criteria, context)
      end

      alias_method :all, :and
      alias_method :any, :or
    end
  end
end
