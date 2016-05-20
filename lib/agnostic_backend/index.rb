module AgnosticBackend
  class Index

    def initialize(indexable_klass)
      @indexable_klass = indexable_klass
    end

    def name
      @indexable_klass.index_name
    end

    def schema
      @indexable_klass.schema
    end

    def indexer
      raise NotImplementedError
    end

    def configure(new_schema = nil)
      raise NotImplementedError
    end

    def parse_option(options, option_name, optional: false, default: nil)
      if options.has_key?(option_name)
        options[option_name]
      elsif optional
        default
      else
        raise "#{option_name} must be specified"
      end
    end
  end
end
