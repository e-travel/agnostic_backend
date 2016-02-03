module AgnosticBackend
  module Indexable

    class Config

      class ConfigEntry < Struct.new(:index_class, :options);
      end

      def self.indices
        @indices ||= {}
      end

      def self.configure_index(indexable_class, index_class, **options)
        indices[indexable_class.name] = ConfigEntry.new index_class, options
      end

      def self.create_index_for(indexable_class)
        entry = indices[indexable_class.name]
        entry.index_class.try(:new, indexable_class, entry.options)
      end

    end
  end
end
