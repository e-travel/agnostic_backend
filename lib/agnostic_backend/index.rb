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
  end
end