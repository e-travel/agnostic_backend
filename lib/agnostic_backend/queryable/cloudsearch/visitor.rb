module AgnosticBackend
  module Queryable
    module Cloudsearch
      class Visitor < AgnosticBackend::Queryable::Visitor

        private

        def visit_criteria_equal(subject)
          "(term field=#{visit(subject.attribute)} #{visit(subject.value)})"
        end

        def visit_criteria_not_equal(subject)
          "(not term field=#{visit(subject.attribute)} #{visit(subject.value)})"
        end

        def visit_criteria_greater(subject)
          "(range field=#{visit(subject.attribute)} {#{visit(subject.value)},})"
        end

        def visit_criteria_less(subject)
          "(range field=#{visit(subject.attribute)} {,#{visit(subject.value)}})"
        end

        def visit_criteria_greater_equal(subject)
          "(range field=#{visit(subject.attribute)} [#{visit(subject.value)},})"
        end

        def visit_criteria_less_equal(subject)
          "(range field=#{visit(subject.attribute)} {,#{visit(subject.value)}])"
        end

        def visit_criteria_greater_and_less(subject)
          "(range field=#{visit(subject.attribute)} {#{visit(subject.left_value)},#{visit(subject.right_value)}})"
        end

        def visit_criteria_greater_equal_and_less(subject)
          "(range field=#{visit(subject.attribute)} [#{visit(subject.left_value)},#{visit(subject.right_value)}})"
        end

        def visit_criteria_greater_and_less_equal(subject)
          "(range field=#{visit(subject.attribute)} {#{visit(subject.left_value)},#{visit(subject.right_value)}])"
        end

        def visit_criteria_greater_equal_and_less_equal(subject)
          "(range field=#{visit(subject.attribute)} [#{visit(subject.left_value)},#{visit(subject.right_value)}])"
        end

        def visit_criteria_contains(subject)
          "(phrase field=#{visit(subject.attribute)} #{visit(subject.value)})"
        end

        def visit_criteria_starts(subject)
          "(prefix field=#{visit(subject.attribute)} #{visit(subject.value)})"
        end

        def visit_criteria_free_text(subject)
          if subject.attribute.any?
            "(and #{visit(subject.value)})"
          else
            "(and #{visit(subject.attribute)}: #{visit(subject.value)})"
          end
        end

        def visit_operations_not(subject)
          "(not #{visit(subject.operand)})"
        end

        def visit_operations_and(subject)
          "(and #{subject.operands.map{|o| visit(o)}.join(' ')})"
        end

        def visit_operations_or(subject)
          "(or #{subject.operands.map{|o| visit(o)}.join(' ')})"
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

        def visit_expressions_filter(subject)
          visit(subject.criterion)
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
          when :integer
            subject.value
          when :date,:date_array
            "'#{subject.value.utc.strftime("%Y-%m-%dT%H:%M:%SZ")}'"
          when :double
            subject.value
          when :boolean
            "'#{subject.value}'"
          when :string,:string_array,:text,:text_array
            "'#{subject.value}'"
          else
            subject.value
          end
        end
      end
    end
  end
end