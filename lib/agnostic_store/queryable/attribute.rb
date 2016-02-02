module AgnosticStore
  module Queryable
    class Attribute < TreeNode
      attr_reader :name, :parent

      def initialize(name, parent: parent, context: context)
        super([], context)
        @name, @parent = name, parent
      end

      def ==(o)
        super && o.name == name
      end
    end
  end
end