module AgnosticBackend
  module Queryable
    module Elasticsearch
      class Visitor < AgnosticBackend::Queryable::Visitor

        private

        def visit_criteria_equal(subject)
          { "match" => { visit(subject.attribute) => visit(subject.value) }
        end

        def visit_criteria_not_equal(subject)
          visit_operations_not(visit_criteria_equal(subject))
        end

        def visit_criteria_greater(subject)
          {
            "range" => {
              visit(subject.attribute) => {
                "gt" => visit(subject.value)
              }
            }
          }
        end

        def visit_criteria_less(subject)
          {
            "range" => {
              visit(subject.attribute) => {
                "lt" => visit(subject.value)
              }
            }
          }
        end

        def visit_criteria_greater_equal(subject)
          {
            "range" => {
              visit(subject.attribute) => {
                "gte" => visit(subject.value)
              }
            }
          }
        end

        def visit_criteria_less_equal(subject)
          {
            "range" => {
              visit(subject.attribute) => {
                "lte" => visit(subject.value)
              }
            }
          }
        end

        def visit_criteria_greater_and_less(subject)
          {
            "range" => {
              visit(subject.attribute) => {
                "gt" => visit(subject.left_value),
                "lt" => visit(subject.right_value)
              }
            }
          }
        end

        def visit_criteria_greater_equal_and_less(subject)
           {
            "range" => {
              visit(subject.attribute) => {
                "gte" => visit(subject.left_value),
                "lt" => visit(subject.right_value)
              }
            }
          }
        end

        def visit_criteria_greater_and_less_equal(subject)
           {
            "range" => {
              visit(subject.attribute) => {
                "gt" => visit(subject.left_value),
                "lte" => visit(subject.right_value)
              }
            }
          }
        end

        def visit_criteria_greater_equal_and_less_equal(subject)
           {
            "range" => {
              visit(subject.attribute) => {
                "gte" => visit(subject.left_value),
                "lte" => visit(subject.right_value)
              }
            }
          }
        end

        def visit_criteria_contains(subject)
          { "match" => { visit(subject.attribute) => visit(subject.value) }
        end

        def visit_criteria_starts(subject)
          { "prefix" => { visit(subject.attribute) => visit(subject.value) } }
        end

        def visit_operations_not(subject)
          { "not" => visit(subject.operand) }
        end

        def visit_operations_and(subject)
          { "must" => subject.operands.map{|o| visit(o)}
        end

        def visit_operations_or(subject)
          { "should" => subject.operands.map{|o| visit(o)}
        end

        def visit_operations_ascending(subject)
          { visit(subject.attribute) => {"order" => "asc" } }
        end

        def visit_operations_descending(subject)
          { visit(subject.attribute) => {"order" => "desc" } }
        end

        def visit_query(subject)
          {
            "query" => subject.children.map{|c| visit(c)}
          }
        end

        def visit_expressions_where(subject)
          { "filtered" => {"filter" => {"bool" => visit(subject.criterion) }}}
        end

        def visit_expressions_select(subject)
          { "source" => subject.projections.map{|c| visit(c)} } #return=
        end

        def visit_expressions_order(subject)
          { "must" => subject.qualifiers.map{|o| visit(o)}
        end

        def visit_expressions_limit(subject)
          { "size" =>  visit(subject.limit) }
        end

        def visit_expressions_offset(subject)
          { "from" =>  visit(subject.offset) }
        end

        def visit_expressions_scroll_cursor(subject)
          { 
            "scroll" => "1m",
            "scroll_id" => visit(subject.scroll_cursor)
          }
        end

        def visit_attribute(subject)
          subject.name.split('.').join('__')
        end

        def visit_value(subject)
          case subject.type
          when :integer
            subject.value
          when :date
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