module AgnosticBackend
  module Queryable
    class Value < TreeNode

      attr_accessor :value
      attr_reader :parent

      def initialize(value, parent: parent, context: context)
        super([], context)
        @value, @parent = value, parent
      end

      def ==(o)
        super && o.value == value
      end

      def associated_attribute
        parent.attribute if parent.respond_to? :attribute
      end

      def type
        associated_attribute.type if associated_attribute.present?
      end
    end
  end
end