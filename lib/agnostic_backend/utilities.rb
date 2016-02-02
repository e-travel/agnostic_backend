module AgnosticBackend
  module Utilities

    def self.included(base)
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods
    end

    module ClassMethods
    end

    module InstanceMethods

      def with_exponential_backoff(error, &block)
        attempts = 0

        begin
          block.call
        rescue error => e
          if attempts < exponential_backoff_max_attempts
            sleep(exponential_backoff_sleep_time(exponential_backoff_max_time, exponential_backoff_base, attempts))
            attempts += 1
            retry
          else
            raise e
          end
        end
      end

      def exponential_backoff_max_time
        @exponential_backoff_max_time ||= 4
      end

      def exponential_backoff_max_attempts
        @exponential_backoff_max_time ||= 10
      end

      def exponential_backoff_base
        @exponential_backoff_max_time ||= 0.2
      end

      def exponential_backoff_sleep_time(max, base, attempts)
        temp = [max, base * 2 ** attempts].min.to_f
        temp/2 + rand(0.0...temp/2)
      end

      def flatten(document, delimiter = '__')
        def flat_hash(document, delimiter)
          flatten_doc = {}
          document.each do |k, v|
            if v.is_a? Hash
              # if we have a nested hash, traverse the hash until we find a value
              # When a value is found, we return it and merge the keys with the key of the previous recursion iteration
              flat_hash(v, delimiter).map do |doc_k, doc_v|
                flatten_doc["#{k}"+ delimiter + "#{doc_k}"] = doc_v
              end
            else
              flatten_doc[k.to_s] = v
            end
          end

          return flatten_doc
        end

        flat_hash(document, delimiter)
      end

      def unflatten(document, delimiter='__')
        unflatten = {}

        def unflatten_hash(hash, delimiter)
          key, value = hash.keys.first, hash.values.first
          components = key.split(delimiter)
          new_key = components.shift
          if components.empty?
            return {new_key => value}
          else
            unflat_hash = {}
            unflat_hash[new_key] = unflatten_hash({components.join(delimiter) => value}, delimiter)
          end

          unflat_hash
        end

        document.each do |k, v|
          unflatten.deep_merge!(unflatten_hash({k => v}, delimiter))
        end

        unflatten
      end

      def transform_nested_values(hash, proc)
        hash.keys.each do |key|
          if hash[key].kind_of? Hash
            transform_nested_values(hash[key], proc)
          else
            hash[key] = proc.call(hash[key])
          end
        end
        hash
      end

      def value_for_key(document, key)
        keys = key.split('.')
        key = keys.shift
        if document.is_a?(Hash)
          if document.has_key? key
            value_for_key(document[key], keys.join('.'))
          else
            return nil
          end
        else
          if document.present? && key.nil?
            return document
          else
            return nil
          end
        end
      end

      def reject_blank_values_from(flat_document)
        flat_document.reject { |_, v| (v.is_a?(FalseClass) ? false : v.blank?) }
      end

      def convert_bool_values_to_string_in(document)
        document.each do |k, v|
          if v.is_a?(TrueClass)
            document[k] = 'true'
          elsif v.is_a?(FalseClass)
            document[k] = 'false'
          end
        end
      end

    end
  end
end