module AgnosticBackend
  module Queryable
    class TreeNode
      # include Enumerable

      attr_reader :children
      attr_reader :context

      def initialize(children = [], context = nil)
        @children, @context = children, context
      end

      # def each(&block)
      #   block.call(self)
      #   children.each{|child| child.each(&block)  }
      # end

      def ==(other)
        return true if self.__id__ == other.__id__
        return false if other.nil?
        return false unless other.is_a? AgnosticBackend::Queryable::TreeNode

        return false unless other.children.size == children.size
        children_pairs = other.children.zip(children)

        other.class == self.class &&
          children_pairs.all? do |first_child, second_child|
            first_child == second_child
          end
      end

      def accept(visitor)
        visitor.visit(self)
      end
    end
  end
end