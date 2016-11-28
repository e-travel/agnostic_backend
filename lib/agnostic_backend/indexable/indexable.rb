module AgnosticBackend
  module Indexable

    class << self
      attr_reader :includers

      def indexable_class(index_name)
        includers.find { |klass| klass.index_name == index_name }
      end
    end

    def self.included(base)
      @includers ||= []
      @includers << base if @includers.none?{|klass| klass.name == base.name}
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods
    end

    module ClassMethods

      def create_index
        AgnosticBackend::Indexable::Config.create_index_for(self)
      end

      def create_indices(include_primary: true)
        AgnosticBackend::Indexable::Config.create_indices_for(self,
                                                              include_primary: include_primary)
      end

      # establishes the convention for determining the index name from the class name
      def index_name(source=nil)
        (source.nil? ? name : source.to_s).split('::').last.underscore.pluralize
      end

      def _index_content_managers
        @__index_content_managers ||= {}
      end

      def index_content_manager(index_name)
        _index_content_managers[index_name.to_s]
      end

      def _index_root_notifiers
        @__index_root_notifiers ||= {}
      end

      def index_root_notifier(index_name)
        _index_root_notifiers[index_name.to_s]
      end

      def schema(for_index: nil, &block)
        index_name = for_index.nil? ? self.index_name : for_index
        manager = index_content_manager(index_name)
        raise "Index #{index_name} has not been defined for #{name}" if manager.nil?
        kv_pairs = manager.contents.map do |field_name, field|
          schema =
              if field.type.nested?
                field.from.map { |klass| klass.schema(for_index: index_name, &block) }.reduce(&:merge)
              elsif block_given?
                yield field.type
              else
                field.type.type
              end
          [field_name, schema]
        end
        Hash[kv_pairs]
      end

      # specifies which fields should be indexed for a given index_name
      # also sets up the manager for the specified index_name
      def define_index_fields(owner: nil, &block)
        return unless block_given?
        _index_content_managers[index_name(owner)] ||= ContentManager.new
        _index_content_managers[index_name(owner)].add_definitions &block
        unless instance_methods(false).include? :_index_content_managers
          define_method(:_index_content_managers) { self.class._index_content_managers }
        end
      end

      # specifies who should be notified when this object is saved
      def define_index_notifier(target: nil, &block)
        return unless block_given?
        _index_root_notifiers[index_name(target)] = block
        unless instance_methods(false).include? :_index_root_notifiers
          define_method(:_index_root_notifiers) { self.class._index_root_notifiers }
        end
      end
    end

    module InstanceMethods

      def index_name(source=nil)
        self.class.index_name(source)
      end

      def generate_document(for_index: nil, observer: nil)
        index_name = for_index.nil? ? self.index_name : for_index.to_s
        return unless respond_to? :_index_content_managers
        manager = _index_content_managers[index_name.to_s]
        raise "Index #{index_name} does not exist" if manager.nil?
        observer ||= AgnosticBackend::Indexable::ObjectObserver.new
        manager.extract_contents_from self, index_name, observer: observer
      end

      def put_to_index(index_name=nil)
        indexable_class = index_name.nil? ?
                            self.class :
                            AgnosticBackend::Indexable.indexable_class(index_name)

        indexable_class.create_indices.map do |index|
          indexer = index.indexer
          indexer.put(self)
        end
      end

      def index_object(index_name)
        put_to_index(index_name)
      end

      private

      def trigger_index_notification
        return unless respond_to? :_index_root_notifiers
        _index_root_notifiers.each do |index_name, block|
          obj = instance_eval &block
          obj = [obj] unless obj.respond_to? :each
          obj.each { |o| o.index_object(index_name) if o.present? }
        end
      end
    end
  end
end
