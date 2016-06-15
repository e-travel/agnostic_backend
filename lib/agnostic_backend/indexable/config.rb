module AgnosticBackend
  module Indexable

    class Config

      class Entry

        attr_reader :index_class,
                    :options

        def initialize(index_class:, indexable_class:, primary: true, **options)
          @index_class = index_class
          @indexable_class = indexable_class
          @primary = primary
          @options = options
        end

        def primary?
          @primary
        end

        def create_index
          @index_class.new(@indexable_class, primary: @primary, **@options)
        end
      end


      def self.indices
        @indices ||= {}
      end

      def self.configure_index(indexable_class, index_class, **options)
        indices[indexable_class.name] = [Entry.new(index_class: index_class,
                                                   indexable_class: indexable_class,
                                                   primary: true,
                                                   **options)]
      end

      def self.configure_secondary_index(indexable_class, index_class, **options)
        unless indices.has_key? indexable_class.name
          raise "No primary index exists for class #{indexable_class.name}"
        end
        indices[indexable_class.name] << Entry.new(index_class: index_class,
                                                   indexable_class: indexable_class,
                                                   primary: false,
                                                   **options)
      end

      def self.create_index_for(indexable_class)
        entry = indices[indexable_class.name].find(&:primary?)
        entry.try(:create_index)
      end

      def self.create_indices_for(indexable_class)
        indices[indexable_class.name].map {|entry| entry.try(:create_index)}.compact
      end

    end
  end
end
