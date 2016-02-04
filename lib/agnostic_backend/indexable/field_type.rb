module AgnosticBackend
  module Indexable
    class FieldType
      INTEGER = :integer
      DOUBLE = :double
      STRING = :string # literal string (i.e. should be matched exactly)
      STRING_ARRAY = :string_array
      TEXT = :text
      TEXT_ARRAY = :text_array
      DATE = :date # datetime
      BOOLEAN = :boolean
      STRUCT = :struct # a nested structure containing other values

      def self.all
        constants.map { |constant| const_get(constant) }
      end

      def self.exists?(type)
        all.include? type
      end

      attr_reader :type, :options

      def initialize(type, **options)
        raise "Type #{type} not supported" unless FieldType.exists? type
        @type = type
        @options = options
      end

      def nested?
        type == STRUCT
      end

      def matches?(type)
        self.type == type
      end

      def get_option(option_name)
        @options[option_name.to_sym]
      end

      def has_option(option_name)
        @options.has_key? option_name.to_sym
      end

    end
  end
end
