module AgnosticBackend
  module Queryable
    class Attribute < TreeNode
      include AgnosticBackend::Utilities

      attr_reader :name, :parent

      def initialize(name, parent:, context:)
        super([], context)
        @name, @parent = name, parent
      end

      def ==(o)
        super && o.name == name
      end

      def type
        value_for_key(context.index.schema, name).try(:type)
      end

      def any?
        @name == '*'
      end

      def score?
        @name == '_score'
      end
    end
  end
end