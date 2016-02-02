module AgnosticBackend
  module Queryable
    module Operations
      class NAry < Operation

        def initialize(operands = [], context = nil)
          super
        end
      end

      class And < NAry;
      end

      class Or < NAry;
      end
    end
  end
end