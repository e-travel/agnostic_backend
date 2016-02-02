module AgnosticBackend
  module Queryable
    module Criteria
      class Ternary < Criterion
        attr_reader :attribute, :left_value, :right_value

        def initialize(attribute:, left_value:, right_value:, context: nil)
          @attribute, @left_value, @right_value = attribute, left_value, right_value
          super([attribute, left_value, right_value], context)
        end
      end

      class Between < Ternary
        def initialize(attribute:, left_value:, right_value:, context: nil)
          attribute = attribute_component(attribute: attribute, context: context)
          left_value = value_component(value: left_value, context: context)
          right_value = value_component(value: right_value, context: context)
          super(attribute: attribute, left_value: left_value, right_value: right_value, context: context)
        end
      end

      class GreaterAndLess < Between;
      end

      class GreaterEqualAndLess < Between;
      end

      class GreaterAndLessEqual < Between;
      end

      class GreaterEqualAndLessEqual < Between;
      end

    end
  end
end