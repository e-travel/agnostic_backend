module AgnosticBackend
  module Queryable
    module Cloudsearch
      class SimpleVisitor < AgnosticBackend::Queryable::Visitor

        private

        def visit_criteria_equal(subject)
          raise UnsupportedNodeError
        end

        def visit_criteria_not_equal(subject)
          raise UnsupportedNodeError
        end

        def visit_criteria_greater(subject)
          raise UnsupportedNodeError
        end

        def visit_criteria_less(subject)
          raise UnsupportedNodeError
        end

        def visit_criteria_greater_equal(subject)
          raise UnsupportedNodeError
        end

        def visit_criteria_less_equal(subject)
          raise UnsupportedNodeError
        end

        def visit_criteria_greater_and_less(subject)
          raise UnsupportedNodeError
        end

        def visit_criteria_greater_equal_and_less(subject)
          raise UnsupportedNodeError
        end

        def visit_criteria_greater_and_less_equal(subject)
          raise UnsupportedNodeError
        end

        def visit_criteria_greater_equal_and_less_equal(subject)
          raise UnsupportedNodeError
        end

        def visit_criteria_contains(subject)
          raise UnsupportedNodeError
        end

        def visit_criteria_starts(subject)
          raise UnsupportedAttributeError unless subject.attribute.any?
          "#{visit(subject.value)}*"
        end

        def visit_criteria_free_text(subject)
          raise UnsupportedAttributeError unless subject.attribute.any?
          "#{visit(subject.value)}"
        end

        def visit_criteria_fuzzy(subject)
          raise UnsupportedAttributeError unless subject.attribute.any?
          "#{visit(subject.value)}~#{subject.fuzziness}"
        end

        def visit_operations_not(subject)
          raise UnsupportedNodeError
        end

        def visit_operations_and(subject)
          raise UnsupportedNodeError
        end

        def visit_operations_or(subject)
          raise UnsupportedNodeError
        end

        def visit_operations_ascending(subject)
          "#{visit(subject.attribute)} asc"
        end

        def visit_operations_descending(subject)
          "#{visit(subject.attribute)} desc"
        end

        def visit_query(subject)
          "#{subject.children.map{|c| visit(c)}.join(' ')}"
        end

        def visit_expressions_where(subject)
          visit(subject.criterion) #search?q=
        end

        def visit_expressions_select(subject)
          "#{subject.projections.map{|c| visit(c)}.join(',')}" #return=
        end

        def visit_expressions_order(subject)
          "#{subject.qualifiers.map{|c| visit(c)}.join(',')}" #sort=
        end

        def visit_expressions_limit(subject)
          visit(subject.limit) #size=
        end

        def visit_expressions_offset(subject)
          visit(subject.offset) #offset=
        end

        def visit_expressions_scroll_cursor(subject)
          visit(subject.scroll_cursor)  #cursor=
        end

        def visit_attribute(subject)
          subject.name.split('.').join('__')
        end

        def visit_value(subject)
          case subject.type
          when :string,:string_array,:text,:text_array
            subject.value
          else
            subject.value
          end
        end
      end
    end
  end
end