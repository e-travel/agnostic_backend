module AgnosticBackend
  module Queryable
    module Operations
      class Unary < Operation
        attr_reader :operand

        def initialize(operand:, context: nil)
          @operand = operand
          super([operand], context)
        end
      end

      class Not < Unary
        def initialize(operand:, context:)
          super(operand: operand, context: context)
        end
      end

      class OrderQualifier < Unary
        def initialize(attribute:, context: nil)
          attribute = attribute_component(attribute: attribute, context: context)
          super(operand: attribute, context: context)
        end

        alias_method :attribute, :operand
      end

      class Ascending < OrderQualifier;
      end

      class Descending < OrderQualifier;
      end
    end
  end
end