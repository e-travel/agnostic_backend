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

      def visit_criteria_not_equal(subject)
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

      def visit_criteria_greater_equal(subject)
        visit(subject.attribute)
        visit(subject.value)
      end

      def visit_criteria_less_equal(subject)
        visit(subject.attribute)
        visit(subject.value)
      end

      def visit_criteria_contains(subject)
        visit(subject.attribute)
        visit(subject.value)
      end

      def visit_criteria_starts(subject)
        visit(subject.attribute)
        visit(subject.value)
      end

      def visit_criteria_greater_and_less(subject)
        visit(subject.attribute)
        visit(subject.left_value)
        visit(subject.right_value)
      end

      def visit_criteria_greater_equal_and_less(subject)
        visit(subject.attribute)
        visit(subject.left_value)
        visit(subject.right_value)
      end

      def visit_criteria_greater_and_less_equal(subject)
        visit(subject.attribute)
        visit(subject.left_value)
        visit(subject.right_value)
      end

      def visit_criteria_greater_equal_and_less_equal(subject)
        visit(subject.attribute)
        visit(subject.left_value)
        visit(subject.right_value)
      end

      def visit_criteria_free_text(subject)
        visit(subject.attribute)
        visit(subject.value)
      end

      def visit_criteria_fuzzy(subject)
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
        visit(subject.criterion)
      end

      def visit_expressions_filter(subject)
        visit(subject.criterion)
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

      def visit_expressions_scroll_cursor(subject)
        visit(subject.scroll_cursor)
      end

      def visit_attribute(subject)
        if value_for_key(subject.context.index.schema, subject.name).nil? && !subject.any?
          subject.context.query.errors[subject.class.name] << attribute_error(subject)
          @valid = false
        end
      end

      def visit_value(subject)
        case subject.type
        when :integer
          unless subject.value.is_a?(Fixnum)
            subject.context.query.errors[subject.class.name] << value_error(subject)
            @valid = false
          end
        when :double
          unless subject.value.is_a?(Float)
            subject.context.query.errors[subject.class.name] << value_error(subject)
            @valid = false
          end
        when :string,:string_array,:text,:text_array
          unless subject.value.is_a?(String)
            subject.context.query.errors[subject.class.name] << value_error(subject)
            @valid = false
          end
        when :date,:date_array
          unless subject.value.is_a?(Time)
            subject.context.query.errors[subject.class.name] << value_error(subject)
            @valid = false
          end
        when :boolean
          unless subject.value.is_a?(TrueClass) || subject.value.is_a?(FalseClass)
            subject.context.query.errors[subject.class.name] << value_error(subject)
            @valid = false
          end
        else
          true
        end
      end

      def value_error(subject)
        "Value #{subject.value} for #{subject.associated_attribute.name} in #{subject.parent.class.name} is defined as #{subject.type} type in schema"
      end

      def attribute_error(subject)
        "Attribute '#{subject.name}' in #{subject.parent.class.name} missing from schema"
      end
    end
  end
end
