module AgnosticStore
  module Queryable
    module Criteria
      class Ternary < Criterion

        def initialize(properties = [], context = nil)
          super
        end

        def attribute
          properties[0]
        end

        def left_value
          properties[1]
        end

        def right_value
          properties[2]
        end
      end

      class Between < Ternary
        def initialize(properties = [], context)
          super(properties_to_attr_value(properties, context), context)
        end

        private

        def properties_to_attr_value(properties, context)
          attribute = Attribute.new(properties[0], parent: self, context: context)
          left_value = Value.new(properties[1], parent: self, context: context)
          right_value = Value.new(properties[2], parent: self, context: context)

          [attribute, left_value, right_value]
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