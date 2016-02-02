module AgnosticBackend
  module Indexable

    class << self
      attr_reader :includers

      def indexable_class(index_name)
        includers.find { |klass| klass.index_name == index_name }
      end
    end

    def self.included(base)
      raise "Can not include Indexable module to a non-ActiveRecord class" unless base < ActiveRecord::Base
      @includers ||= []
      @includers << base unless @includers.include? base
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods
    end

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

      attr_reader :type

      def initialize(type, **options)
        raise "Type #{type} not supported" unless FieldType.exists? type
        @type = type
        @options = options
      end

      def nested?
        type == STRUCT
      end

      def get_option(option_name)
        @options[option_name.to_sym]
      end

      def has_option(option_name)
        @options.has_key? option_name.to_sym
      end

    end

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

      def extract_contents_from(object, index_name)
        kv_pairs = contents.map do |field_name, field|
          field_value = field.evaluate(context: object)
          if field.type.nested?
            if field_value.respond_to? :generate_document
              field_value = field_value.generate_document(for_index: index_name)
            elsif field_value.present?
              field_name = nil
            end
          end
          [field_name, field_value]
        end
        kv_pairs.reject! { |attr_name, _| attr_name.nil? }
        Hash[kv_pairs]
      end

    end

    module ClassMethods

      def create_index
        AgnosticBackend::Indexable::Config.create_index_for(self)
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
          send :after_commit, :trigger_index_notification_on_save
        end
      end
    end

    module InstanceMethods

      def index_name(source=nil)
        self.class.index_name(source)
      end

      def generate_document(for_index: nil)
        index_name = for_index.nil? ? self.index_name : for_index.to_s
        return unless respond_to? :_index_content_managers
        manager = _index_content_managers[index_name.to_s]
        raise "Index #{index_name} does not exist" if manager.nil?
        manager.extract_contents_from self, index_name
      end

      def put_in_index
        index = self.class.create_index
        indexer = index.indexer
        indexer.put(self)
      end

      def enqueue_for_indexing(index_name)
        index_name = index_name.to_s
        return unless _index_content_managers.has_key? index_name
        item = AgnosticBackend::DocumentBufferItem.create!(model_id: id,
                                                           model_type: self.class.name,
                                                           index_name: index_name)
        item.schedule_indexing
      end

      private

      def trigger_index_notification_on_save
        return unless respond_to? :_index_root_notifiers
        _index_root_notifiers.each do |index_name, block|
          obj = instance_eval &block
          obj = [obj] unless obj.is_a? Enumerable
          obj.each { |o| o.enqueue_for_indexing(index_name) if o.present? }
        end
      end
    end
  end
end
