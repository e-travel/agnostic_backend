module AgnosticBackend
  module Cloudsearch
    class RemoteIndexField

      attr_reader :field, :status

      # returns an array with two elements:
      # the first is an array with the remote fields that correspond to local fields
      # the second is an array with the remote that do not have corresponding local fields
      def self.partition(local_fields, remote_fields)
        local_field_names = local_fields.map(&:name)
        remote_fields.partition do |remote_field|
          local_field_names.include? remote_field.index_field_name
        end
      end

      def initialize(remote_field_struct)
        @field = remote_field_struct.options
        @status = remote_field_struct.status
      end

      def method_missing(method_name)
        if field.respond_to?(method_name)
          field.send(method_name)
        else
          super
        end
      end

    end
  end
end
