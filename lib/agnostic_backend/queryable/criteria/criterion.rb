module AgnosticBackend
  module Queryable
    module Criteria
      class Criterion < TreeNode
        def initialize(components = [], context = nil)
          super
        end

        alias_method :components, :children
      end
    end
  end
end