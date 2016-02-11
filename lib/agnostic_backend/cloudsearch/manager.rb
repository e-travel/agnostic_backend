module AgnosticBackend
  module Cloudsearch
    class Manager

      def initialize(index_name:, verbose: false)
        @indexable_class = AgnosticBackend::Indexable.indexable_class(index_name)
        @indexer = @indexable_class.create_index.indexer
        @verbose = verbose
      end

      def run(start_id:, end_id:, batch_size:)
        indexables(start_id: start_id, end_id: end_id, batch_size: batch_size) do |group|
          batch = batch_for(group: group)
          split_in_document_batches(batch: batch).each do |document_batch|
            process_document_batch(document_batch: document_batch)
          end
        end
      rescue => e
        # Rails.logger.error "Document Indexing: Batch upload error while processing with #{e.class.name}: #{e.message}"
        puts "error while processing with #{e.class.name}: #{e.message}" if @verbose
      end

      def run_for(ids:, batch_size:)
        indexables_for(ids: ids, batch_size: batch_size) do |group|
          batch = batch_for(group: group)
          split_in_document_batches(batch: batch).each do |document_batch|
            process_document_batch(document_batch: document_batch)
          end
        end
      rescue => e
        # Rails.logger.error "Document Indexing: Batch upload error while processing #{ids} with #{e.class.name}: #{e.message}"
        puts "error while processing with #{e.class.name}: #{e.message}" if @verbose
      end

      private

      def process_document_batch(document_batch:)
        puts "indexing tasks [start_id: #{document_batch.first['id']}, end_id: #{document_batch.last['id']}]" if @verbose
        document = prepare_document_batch(document_batch: document_batch)
        begin
          publish_document(document: document)
        rescue => e
          # Rails.logger.error "Document Indexing: Batch upload error while processing [start_id: #{document_batch.first['id']}, end_id: #{document_batch.last['id']}] with #{e.class.name}: #{e.message}"
          puts "error while [start_id: #{document_batch.first['id']}, end_id: #{document_batch.last['id']}] with #{e.class.name}: #{e.message}" if @verbose
        end
      end

      def batch_for(group:)
        group.map do |indexable|
          begin
            to_document(indexable: indexable)
          rescue => e
            # Rails.logger.error "Document Indexing: Batch upload error while processing #{indexable.id} with #{e.class.name}: #{e.message}"
            puts "error while processing #{indexable.id} with #{e.class.name}: #{ e.message}" if @verbose
          end
        end
      end

      def indexables(start_id:, end_id:, batch_size:)
        @indexable_class.where('id >= ?', start_id).where('id <= ?', end_id).
            find_in_batches(start: 1, batch_size: batch_size) { |group| yield group }
      end

      def indexables_for(ids:, batch_size:)
        @indexable_class.where(id: ids).find_in_batches(start: 1, batch_size: batch_size) { |group| yield group }
      end

      def to_document(indexable:)
        document = indexable.generate_document
        document = @indexer.send(:flatten, document)
        document = @indexer.send(:reject_blank_values_from, document)
        document = @indexer.send(:convert_bool_values_to_string_in, document)
        document = @indexer.send(:date_format, document)
        document = @indexer.send(:add_metadata_to, document)
        document
      end

      def split_in_document_batches(batch:)
        document_batch = @indexer.send(:convert_to_json, batch)

        document_size = document_batch.bytesize

        split_count = split_count(document_size: document_size)
        if split_count > 1
          batch.in_groups(split_count, false)
        else
          [batch]
        end
      end

      def split_count(document_size:)
        (document_size/ max_document_size).ceil
      end

      def max_document_size
        @max_document_size ||= 4500000.to_f
      end

      def prepare_document_batch(document_batch:)
        document_batch = @indexer.send(:convert_to_json, document_batch)
        document_batch
      end

      def publish_document(document:)
        @indexer.send(:publish, document)
      end
    end
  end
end