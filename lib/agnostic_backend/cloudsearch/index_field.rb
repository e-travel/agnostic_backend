require "aws-sdk"

module AgnosticBackend
  module Cloudsearch
    class IndexField
      include AgnosticBackend::Utilities

      TYPE_MAPPINGS = {
        AgnosticBackend::Indexable::FieldType::STRING => "literal",
        AgnosticBackend::Indexable::FieldType::STRING_ARRAY => "literal-array",
        AgnosticBackend::Indexable::FieldType::DATE => "date",
        AgnosticBackend::Indexable::FieldType::DATE_ARRAY=> "date-array",
        AgnosticBackend::Indexable::FieldType::INTEGER => "int",
        AgnosticBackend::Indexable::FieldType::DOUBLE => "double",
        AgnosticBackend::Indexable::FieldType::BOOLEAN => "literal",
        AgnosticBackend::Indexable::FieldType::TEXT => "text",
        AgnosticBackend::Indexable::FieldType::TEXT_ARRAY => "text-array",
      }.freeze

      attr_reader :name, :type

      def initialize(name, type)
        @name = name
        @type = type
      end

      def define_in_domain(index: )
        with_exponential_backoff Aws::CloudSearch::Errors::Throttling do
          index.cloudsearch_client.define_index_field(
            :domain_name => index.domain_name,
            :index_field => definition
          )
        end
      end

      def equal_to_remote_field?(remote_field)
        remote_options = remote_field.send(options_name.to_sym)
        local_options = options

        remote_field.index_field_name == name.to_s &&
          remote_field.index_field_type == cloudsearch_type &&
          local_options.all?{|k, v| v == remote_options.send(k) }
      end

      def sortable?
        type.has_option(:sortable) ? !!type.get_option(:sortable) : true
      end

      def searchable?
        type.has_option(:searchable) ? !!type.get_option(:searchable) : true
      end

      def returnable?
        type.has_option(:returnable) ? !!type.get_option(:returnable) : true
      end

      def facetable?
        type.has_option(:facetable) ? !!type.get_option(:facetable) : false
      end

      private

      def cloudsearch_type
        @cloudsearch_type ||= TYPE_MAPPINGS[type.type]
      end

      def definition
        {
          :index_field_name => name.to_s,
          :index_field_type => cloudsearch_type,
          options_name.to_sym => options
        }
      end

      def options_name
        "#{cloudsearch_type.gsub('-', '_')}_options"
      end

      def options
        opts = {
            :sort_enabled => sortable?,
            :search_enabled => searchable?,
            :return_enabled => returnable?,
            :facet_enabled => facetable?
          }
        # certain parameters are not included acc. to cloudsearch type
        # we filter them out here
        case cloudsearch_type
        when 'text-array'
          opts.delete(:sort_enabled)
          opts.delete(:search_enabled)
          opts.delete(:facet_enabled)
        when 'text'
          opts.delete(:search_enabled)
          opts.delete(:facet_enabled)
        when 'literal-array'
          opts.delete(:sort_enabled)
        when 'date-array'
          opts.delete(:sort_enabled)
        end
        opts
      end

    end
  end
end