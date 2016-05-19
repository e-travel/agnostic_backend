module AgnosticBackend
  module Elasticsearch

    class RemoteIndexField

      attr_reader :name, :type

      def initialize(name, type, **args)
        @name = name
        @type = to_local type
        @options = args
      end

      def method_missing(method_name)
        if options.has_key? method_name
          @options[method_name]
        else
          super
        end
      end

      private

      def to_local(remote_type)
        AgnosticBackend::Elasticsearch::IndexField::TYPE_MAPPINGS.find{|ltype, rtype| remote_type == rtype}.try(:last)
      end

    end

  end
end
