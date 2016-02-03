module AgnosticBackend
  module Queryable
    module Cloudsearch
      class ResultSet < AgnosticBackend::Queryable::ResultSet
        include AgnosticBackend::Utilities

        def total_count
          raw_results.hits.found
        end

        def cursor
          raw_results.hits.cursor
        end

        private

        def filtered_results
          raw_results.hits.hit.map(&:fields)
        end

        def transform(result)
          transform_nested_values(unflatten(result), Proc.new{|value| value.size > 1 ? value.split.join('|') : value.first})
        end
      end
    end
  end
end