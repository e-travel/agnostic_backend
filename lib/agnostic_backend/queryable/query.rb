module AgnosticBackend
  module Queryable
    class Query < TreeNode
      attr_accessor :errors
      attr_reader :context
      attr_reader :executor
      attr_reader :options

      def initialize(context, **options)
        super()
        @errors ||= Hash.new { |hash, key| hash[key] = Array.new }
        @context = context
        @options = options
      end

      def execute
        raise NotImplementedError
      end

      def valid?
        self.accept(AgnosticBackend::Queryable::Validator.new)
      end

     def set_scroll_cursor(value)
        context.scroll_cursor(value)
        context.build
      end
    end
  end
end