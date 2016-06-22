module AgnosticBackend
  module Queryable
    module Elasticsearch
      class QueryBuilder < AgnosticBackend::Queryable::QueryBuilder
        private

        def create_query(context)
          AgnosticBackend::Queryable::Elasticsearch::Query.new(context)
        end
      end
    end
  end
end