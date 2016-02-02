module AgnosticBackend
  module Queryable
    class ResultSet

      include Enumerable

      attr_reader :raw_results, :query

      def initialize(raw_results, query)
        @raw_results, @query = raw_results, query
      end

      def each(&block)
        filtered_results.each do |result|
          block.call(transform(result))
        end
      end

      def empty?
        none?
      end

      def total_count
        raise NotImplementedError
      end

      def offset
        raise NotImplementedError
      end

      private

      def filtered_results
        raise NotImplementedError
      end

      def transform(result)
        raise NotImplementedError
      end
    end
  end
end