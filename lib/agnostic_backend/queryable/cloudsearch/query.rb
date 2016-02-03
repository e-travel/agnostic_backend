module AgnosticBackend
  module Queryable
    module Cloudsearch
      class Query < AgnosticBackend::Queryable::Query

        def initialize(base)
          super
          @executor = Executor.new(self, Visitor.new)
        end

        def execute
          @executor.execute if valid?
        end

        def execute!
          if valid?
            @executor.execute
          else
            raise StandardError, errors
          end
        end

        def set_cursor(value)
          base.cursor(value)
          base.build
        end

        def to_s
          @executor.to_s
        end
      end
    end
  end
end