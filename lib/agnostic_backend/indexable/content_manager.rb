module AgnosticBackend
  module Indexable

    class ContentManager

      def add_definitions &block
        return unless block_given?
        instance_eval &block
      end

      def contents
        @contents ||= {}
      end

      def method_missing(sym, *args, **kwargs)
        if FieldType.exists? sym
          kwargs[:type] = sym
          field(*args, **kwargs)
        else
          super
        end
      end

      def respond_to?(sym, include_private=false)
        FieldType.exists?(sym) || super
      end

      def field(field_name, value: nil, type:, from: nil, **options)
        contents[field_name.to_s] = Field.new(value.present? ? value : field_name, type,
                                              from: from, **options)
      end

      def extract_contents_from(object, index_name, observer:)
        result = {}
        kv_pairs = contents.map do |field_name, field|
          field_value = field.evaluate(context: object)
          if field.type.nested?
            if field_value.respond_to? :generate_document
              observer.add(field_value)
              result[field_name] = field_value.generate_document(for_index: index_name, observer: observer)
            elsif field_value.present?
              next
            else
              result[field_name] = field_value
            end
          else
            result[field_name] = field_value
          end
        end
        result
      end

    end
  end
end
