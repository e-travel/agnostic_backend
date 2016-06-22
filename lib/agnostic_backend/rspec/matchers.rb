module AgnosticBackend
  module RSpec
    module Matchers
      class BeIndexable
        def matches?(actual)
          actual < AgnosticBackend::Indexable
        end

        def description
          "include AgnosticBackend::Indexable"
        end
      end

      def be_indexable
        BeIndexable.new
      end

      class DefineIndexField
        def initialize(name, for_index: nil, type: nil, **expected_custom_attributes)
          @name = name
          @for_index = for_index
          @type = type
          @expected_custom_attributes = expected_custom_attributes
        end

        def matches?(klass)
          @for_index ||= klass.index_name
          manager = klass.index_content_manager(@for_index)
          manager.nil? and return false
          field = manager.contents[@name.to_s]
          field.nil? and return false
          type_matches?(field, @type) &&
            custom_attributes_match?(field, @expected_custom_attributes) rescue false
        end

        def description
          expectation_message
        end

        def failure_message
          "expected to #{expectation_message}"
        end

        private

        def expectation_message
          "define the index field :#{@name}" +
            (@type.nil? ? "" : " with type :#{@type}") +
            (@for_index.nil? ? "" : " for index '#{@for_index}'" )
        end

        def type_matches?(field, expected_type)
          return true if expected_type.nil?
          field.type.matches?(expected_type)
        end

        def custom_attributes_match?(field, expected_attributes)
          return true if expected_attributes.empty?
          field.type.options == expected_attributes
        end
      end

      def define_index_field(*args)
        DefineIndexField.new(*args)
      end
    end
  end
end
