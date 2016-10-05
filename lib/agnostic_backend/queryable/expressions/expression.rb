module AgnosticBackend
  module Queryable
    module Expressions
      class Expression < TreeNode
      end

      class Where < Expression
        def initialize(criterion:, context:)
          super([criterion], context)
        end

        def criterion
          children.first
        end
      end


      class Filter < Expression
        def initialize(criterion:, context:)
          super([criterion], context)
        end

        def criterion
          children.first
        end
      end

      class Select < Expression
        def initialize(attributes:, context:)
          super(attributes.map { |a| Attribute.new(a, parent: self, context: context) }, context)
        end

        alias_method :projections, :children
      end

      class Order < Expression
        def initialize(attributes:, context:)
          super(attributes, context)
        end

        alias_method :qualifiers, :children
      end

      class Limit < Expression
        def initialize(value:, context:)
          super([Value.new(value, parent: self, context: context)], context)
        end

        def limit
          children.first
        end
      end

      class Offset < Expression
        def initialize(value:, context:)
          super([Value.new(value, parent: self, context: context)], context)
        end

        def offset
          children.first
        end
      end

      class ScrollCursor < Expression
        def initialize(value:, context:)
          super([Value.new(value, parent: self, context: context)], context)
        end

        def scroll_cursor
          children.first
        end
      end

    end
  end
end