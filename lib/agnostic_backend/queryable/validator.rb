module AgnosticBackend
  module Queryable
    class Validator < AgnosticBackend::Queryable::Visitor

      include AgnosticBackend::Utilities

      def initialize
        @valid = true
      end

      private

      def visit_query(subject)
        subject.children.each { |c| visit(c) }
        @valid
      end

      def visit_criteria_equal(subject)
        visit(subject.attribute)
        visit(subject.value)
      end

      def visit_criteria_notequal(subject)
        visit(subject.attribute)
        visit(subject.value)
      end

      def visit_criteria_greater(subject)
        visit(subject.attribute)
        visit(subject.value)
      end

      def visit_criteria_less(subject)
        visit(subject.attribute)
        visit(subject.value)
      end

      def visit_criteria_greaterequal(subject)
        visit(subject.attribute)
        visit(subject.value)
      end

      def visit_criteria_lessequal(subject)
        visit(subject.attribute)
        visit(subject.value)
      end

      def visit_criteria_greaterandless(subject)
        visit(subject.attribute)
        visit(subject.left_value)
        visit(subject.right_value)
      end

      def visit_criteria_greaterequalandless(subject)
        visit(subject.attribute)
        visit(subject.left_value)
        visit(subject.right_value)
      end

      def visit_criteria_greaterandlessequal(subject)
        visit(subject.attribute)
        visit(subject.left_value)
        visit(subject.right_value)
      end

      def visit_criteria_greaterequalandlessequal(subject)
        visit(subject.attribute)
        visit(subject.left_value)
        visit(subject.right_value)
      end

      def visit_criteria_contain(subject)
        visit(subject.attribute)
        visit(subject.value)
      end

      def visit_criteria_start(subject)
        visit(subject.attribute)
        visit(subject.value)
      end

      def visit_operations_not(subject)
        visit(subject.operand)
      end

      def visit_operations_and(subject)
        subject.operands.each { |o| visit(o) }
      end

      def visit_operations_or(subject)
        subject.operands.each { |o| visit(o) }
      end

      def visit_operations_ascending(subject)
        visit(subject.attribute)
      end

      def visit_operations_descending(subject)
        visit(subject.attribute)
      end

      def visit_expressions_where(subject)
        subject.restrictions.each { |c| visit(c) }
      end

      def visit_expressions_select(subject)
        subject.projections.each { |c| visit(c) }
      end

      def visit_expressions_order(subject)
        subject.qualifiers.each { |c| visit(c) }
      end

      def visit_expressions_limit(subject)
        visit(subject.limit)
      end

      def visit_expressions_offset(subject)
        visit(subject.offset)
      end

      def visit_cloudsearch_expressions_cursor(subject)
        visit(subject.cursor)
      end

      def visit_attribute(subject)
        if value_for_key(subject.context.index.schema, subject.name).nil?
          subject.context.query.errors[subject.class.name] << "Attribute '#{subject.name}' in #{subject.parent.class.name} missing from schema"
          @valid = false
        end
      end

      def visit_value(subject)
        true
      end
    end
  end
end
