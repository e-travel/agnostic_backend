module AgnosticBackend
  module Queryable
    module Cloudsearch
      class QueryBuilder < AgnosticBackend::Queryable::QueryBuilder
        private

        def create_query(context, **options)
          AgnosticBackend::Queryable::Cloudsearch::Query.new(context, **options)
        end
      end
    end
  end
end