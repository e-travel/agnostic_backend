module AgnosticBackend
  module Queryable
    class Visitor
      def visit(subject)
        method_name = class_to_method_name(subject.class)
        send(method_name, subject)
      end

      def class_to_method_name(klass)
        if klass.name.split('::').last == 'Query'
          'visit_query'
        else
          "visit_#{klass.name.split('Queryable::').last.gsub('::', '_').downcase}"
        end
      end

      private

      def visit_operations_equal(subject)
        raise NotImplementedError
      end

      def visit_operations_notequal(subject)
        raise NotImplementedError
      end

      def visit_operations_greater(subject)
        raise NotImplementedError
      end

      def visit_operations_less(subject)
        raise NotImplementedError
      end

      def visit_operations_greaterequal(subject)
        raise NotImplementedError
      end

      def visit_operations_lessequal(subject)
        raise NotImplementedError
      end

      def visit_operations_greaterandless(subject)
        raise NotImplementedError
      end

      def visit_operations_greaterequalandless(subject)
        raise NotImplementedError
      end

      def visit_operations_greaterandlessequal(subject)
        raise NotImplementedError
      end

      def visit_operations_greaterequalandlessequal(subject)
        raise NotImplementedError
      end

      def visit_operations_not(subject)
        raise NotImplementedError
      end

      def visit_operations_and(subject)
        raise NotImplementedError
      end

      def visit_operations_or(subject)
        raise NotImplementedError
      end

      def visit_operations_ascending(subject)
        raise NotImplementedError
      end

      def visit_operations_descending(subject)
        raise NotImplementedError
      end

      def visit_operations_contain(subject)
        raise NotImplementedError
      end

      def visit_operations_start(subject)
        raise NotImplementedError
      end

      def visit_query(subject)
        raise NotImplementedError
      end

      def visit_expressions_where(subject)
        raise NotImplementedError
      end

      def visit_expressions_select(subject)
        raise NotImplementedError
      end

      def visit_expressions_order(subject)
        raise NotImplementedError
      end

      def visit_expressions_limit(subject)
        raise NotImplementedError
      end

      def visit_expressions_offset(subject)
        raise NotImplementedError
      end

      def visit_attribute(subject)
        raise NotImplementedError
      end

      def visit_value(subject)
        raise NotImplementedError
      end
    end
  end
end