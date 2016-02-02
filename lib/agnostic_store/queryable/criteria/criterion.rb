module AgnosticStore
  module Queryable
    module Criteria
      class Criterion < TreeNode
        def initialize(properties = [], context = nil)
          super
        end

        alias_method :properties, :children
      end
    end
  end
end