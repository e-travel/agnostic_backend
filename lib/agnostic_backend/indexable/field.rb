module AgnosticBackend
  module Indexable

    class Field

      attr_accessor :value, :type, :from

      def initialize(value, type, from: nil, **options)
        if type == FieldType::STRUCT && from.nil?
          raise "A nested type requires the specification of a target class using the `from` argument"
        end
        @value = value.respond_to?(:call) ? value : value.to_sym
        @from = (from.is_a?(Enumerable) ? from : [from]) unless from.nil?
        @type = FieldType.new(type, **options)
      end

      def evaluate(context:)
        value.respond_to?(:call) ?
          context.instance_eval(&value) :
          context.send(value)
      end

    end

  end
end
