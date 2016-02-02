module AgnosticStore
  class Indexer

    attr_reader :index

    def initialize(index)
      @index = index
    end

    # Sends the specified document to the remote backend.
    # This is a template method.
    # @param [Indexable] an Indexable object
    # @returns [boolean] true if success, false if failure
    # returns nil if no indexing attempt is made (e.g. generated document is empty)
    def put(indexable)
      document = indexable.generate_document
      return if document.blank?
      begin
        publish(transform(prepare(document)))
        true
      rescue => e
        false
      end
    end

    # Deletes the specified document from the index, This is an abstract
    # method which concrete index classes must implement in order to provide
    # its functionality.
    # @param [document_id] the document id of the indexed document
    def delete(document_id)
      raise NotImplementedError
    end

    private

    def publish(document)
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