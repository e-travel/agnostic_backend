module AgnosticBackend
  module Indexable

    class CircularReferenceError < StandardError; end

    class ObjectObserver
      def initialize
        @objects = Set.new
      end

      def add(obj)
        raise CircularReferenceError.new(obj) if @objects.include? obj
        @objects << obj
      end
    end
  end
end
