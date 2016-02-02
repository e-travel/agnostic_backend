module AgnosticBackend
  module Queryable
    class Query < TreeNode
      attr_accessor :errors
      attr_reader :context

      def initialize(context)
        super()
        @errors ||= Hash.new { |hash, key| hash[key] = Array.new }
        @context = context
      end

      def execute
        raise NotImplementedError
      end

      def valid?
        self.accept(AgnosticBackend::Queryable::Validator.new)
      end
    end
  end
end