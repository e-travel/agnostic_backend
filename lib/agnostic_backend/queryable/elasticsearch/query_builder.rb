module AgnosticBackend
  module Queryable
    module Elasticsearch
      class QueryBuilder < AgnosticBackend::Queryable::QueryBuilder
        private

        def create_query(context, **options)
          AgnosticBackend::Queryable::Elasticsearch::Query.new(context, **options)
        end
      end
    end
  end
end