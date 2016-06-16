module AgnosticBackend

  class IndexingError < StandardError; end

  class Indexer

    attr_reader :index

    def initialize(index)
      @index = index
    end

    # Sends the specified document to the remote backend.
    # @param [Indexable] an Indexable object
    def put(indexable)
      put_all([indexable])
    end

    # Sends the specified documents to the remote backend
    # using bulk upload (if supported by the backend)
    # @param [Indexable] an Indexable object
    def put_all(indexables)
      documents = indexables.map do |indexable|
        transform(prepare(indexable.generate_document))
      end
      documents.reject!(&:empty?)
      publish_all(documents) unless documents.empty?
    end

    # Deletes the specified document from the index
    # @param [document_id] the document id of the indexed document
    def delete(document_id)
      delete_all([document_id])
    end

    # Deletes the specified documents from the index.
    # This is an abstract method which concrete index classes
    # must implement in order to provide its functionality.
    # @param [document_ids] an array of document ids
    def delete_all(document_ids)
      raise NotImplementedError
    end

    private

    def publish(document)
      publish_all([document])
    end

    def publish_all(documents)
      raise NotImplementedError
    end

    def transform(document)
      raise NotImplementedError
    end

    def prepare(document)
      raise NotImplementedError
    end
  end
end
