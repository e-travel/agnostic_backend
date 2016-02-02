module AgnosticBackend
  module Queryable
    module Criteria
      class Binary < Criterion
        def initialize(properties = [], base = nil)
          super
        end

        def attribute
          properties[0]
        end

        def value
          properties[1]
        end
      end

      class Relational < Binary

        def initialize(properties = [], context = nil)
          super(properties_to_attr_value(properties, context), context)
        end

        private

        def properties_to_attr_value(properties, context)
          attribute = Attribute.new(properties[0], parent: self, context: context)
          value = Value.new(properties[1], parent: self, context: context)

          [attribute, value]
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

      class Contain < Relational;
      end

      class Start < Relational;
      end
    end
  end
end