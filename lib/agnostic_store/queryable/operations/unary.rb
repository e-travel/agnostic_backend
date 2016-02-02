module AgnosticStore
  module Queryable
    module Operations
      class Unary < Operation

        def initialize(operands = [], context = nil)
          super
        end

        def operand
          operands[0]
        end
      end

      class Not < Unary
        def initialize(operand, context)
          super
        end
      end

      class OrderQualifier < Unary
        def initialize(attribute = [], context = nil)
          super(map_attribute(attribute, context), context)
        end

        alias_method :attribute, :operand

        private

        def map_attribute(attribute, context)
          attribute = Attribute.new(attribute, parent: self, context: context)
          [attribute]
        end
      end

      class Ascending < OrderQualifier;
      end

      class Descending < OrderQualifier;
      end
    end
  end
end