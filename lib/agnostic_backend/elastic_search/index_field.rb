
module AgnosticBackend
  module Elasticsearch
    class IndexField

    	 TYPE_MAPPINGS = {
        AgnosticBackend::Indexable::FieldType::STRING => "string",
        AgnosticBackend::Indexable::FieldType::STRING_ARRAY => "string",
        AgnosticBackend::Indexable::FieldType::DATE => "date",
        AgnosticBackend::Indexable::FieldType::INTEGER => "integer",
        AgnosticBackend::Indexable::FieldType::DOUBLE => "double",
        AgnosticBackend::Indexable::FieldType::BOOLEAN => "boolean",
        AgnosticBackend::Indexable::FieldType::TEXT => "string",
        AgnosticBackend::Indexable::FieldType::TEXT_ARRAY => "string",
      }.freeze

      attr_reader :name, :type

      def initialize(name, type)
        @name = name
        @type = type
      end

      def define_in_domain(index:)
        index.elasticsearch_client.define_index_field(
          endpoint: index.endpoint, 
          index_name: index.index_name, 
          type: index.type,
          definition: definition
        )
      end

      def analyzed?
      	type.has_option(:analyzed) ? !!type.get_option(:analyzed) : false
      end


      private

      def elasticsearch_type
        @elasticsearch_type ||= TYPE_MAPPINGS[type.type]
      end

      def definition
        {
          name.to_s => {
              "type" => elasticsearch_type
            }.merge(analyzed_property)
        }
      end

      def analyzed_property
        analyzed? ? {} : { "index" => "not_analyzed" }
      end

		end
	end
end
