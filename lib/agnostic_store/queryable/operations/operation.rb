module AgnosticStore
  module Queryable
    module Operations
      class Operation < TreeNode
        def initialize(operands = [], context = nil)
          super
        end

        alias_method :operands, :children
      end
    end
  end
end