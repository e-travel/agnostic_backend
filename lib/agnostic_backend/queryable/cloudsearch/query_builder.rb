module AgnosticBackend
  module Queryable
    module Cloudsearch
      class QueryBuilder < AgnosticBackend::Queryable::QueryBuilder
        private

        def create_query(context)
          AgnosticBackend::Queryable::Cloudsearch::Query.new(context)
        end
      end
    end
  end
end