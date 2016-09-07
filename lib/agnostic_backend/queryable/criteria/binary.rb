module AgnosticBackend
  module Queryable
    module Criteria
      class Binary < Criterion
        attr_reader :attribute, :value

        def initialize(attribute:, value:, context: nil)
          @attribute, @value = attribute, value
          super([attribute, value], context)
        end
      end

      class Relational < Binary

        def initialize(attribute:, value:, context: nil)
          attribute = attribute_component(attribute: attribute, context: context)
          value = value_component(value: value, context: context, type: attribute.type)
          super(attribute: attribute, value: value, context: context)
        end
      end

      class Equal < Relational;
      end

      class NotEqual < Relational;
      end

      class Greater < Relational;
      end

      class Less < Relational;
      end

      class GreaterEqual < Relational;
      end

      class LessEqual < Relational;
      end

      class Contains < Relational;
      end

      class Starts < Relational;
      end

      class FreeText < Relational;
      end
    end
  end
end