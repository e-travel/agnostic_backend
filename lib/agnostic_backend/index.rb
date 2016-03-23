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

    def parse_option(options, option_name)
      if options.has_key?(option_name)
        options[option_name]
      else
        raise "#{option_name} must be specified"
      end
    end
  end
end
