module AgnosticBackend
  module Queryable
    module Elasticsearch
      class ResultSet < AgnosticBackend::Queryable::ResultSet
        include AgnosticBackend::Utilities

        def total_count
          raw_results["hits"]["total"]
        end

        def scroll_cursor
          raw_results["_scroll_id"]
        end

        private

        def filtered_results
          raw_results["hits"]["hits"].map{|h| h["fields"]}
        end

        def transform(result)
          transform_nested_values(unflatten(result), Proc.new{|value| value.size > 1 ? value.split.join('|') : value.first})
        end
      end
    end
  end
end
