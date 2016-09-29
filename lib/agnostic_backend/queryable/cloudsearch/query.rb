module AgnosticBackend
  module Queryable
    module Cloudsearch
      class Query < AgnosticBackend::Queryable::Query

        def initialize(base, **options)
          super
          case options[:parser]
          when :simple
            @executor = Executor.new(self, SimpleVisitor.new)
          else
            @executor = Executor.new(self, Visitor.new)
          end
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

        def to_s
          @executor.to_s
        end
      end
    end
  end
end