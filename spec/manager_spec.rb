require 'spec_helper'

describe AgnosticBackend::Cloudsearch::Manager do

  before do
    Object.send(:remove_const, :IndexableObject) if Object.constants.include? :IndexableObject
    class IndexableObject; end
    IndexableObject.send(:include, AgnosticBackend::Indexable)

    if AgnosticBackend::Indexable::Config.indices[IndexableObject.name].nil?
      AgnosticBackend::Indexable::Config.configure_index(
        IndexableObject,
        AgnosticBackend::Cloudsearch::Index,
        access_key_id: 'the_access_key_id',
        secret_access_key: 'the_secret_access_key',
        region: 'the_region',
        domain_name: 'the_domain_name',
        document_endpoint: 'the_document_endpoint',
        search_endpoint: 'the_search_endpoint'
      )
    end
  end

  subject { AgnosticBackend::Cloudsearch::Manager.new(index_name: 'indexable_objects') }
  let(:indexable) { IndexableObject.new }


  describe '#to_document' do
    let(:document) {
      {'id' => 1, 'field' => 'value'}
    }
    it 'should generate document' do
      expect(indexable).to receive(:generate_document).and_return(document)
      subject.send(:to_document, indexable: indexable)
    end

    it 'should successively call flatten, reject_blank_values, convert_bool_values, date_format and add_metadata on indexer' do

      allow(indexable).to receive(:generate_document).and_return(document)
      expect_any_instance_of(AgnosticBackend::Cloudsearch::Indexer).to receive(:flatten).with(document).and_call_original
      expect_any_instance_of(AgnosticBackend::Cloudsearch::Indexer).to receive(:reject_blank_values_from).and_call_original
      expect_any_instance_of(AgnosticBackend::Cloudsearch::Indexer).to receive(:convert_bool_values_to_string_in).and_call_original
      expect_any_instance_of(AgnosticBackend::Cloudsearch::Indexer).to receive(:date_format).and_call_original
      expect_any_instance_of(AgnosticBackend::Cloudsearch::Indexer).to receive(:add_metadata_to).and_call_original

      expect(subject.send(:to_document, indexable: indexable)).to eq({'type'=>'add', 'id'=>'1', 'fields'=>{'id' => 1, 'field'=>'value'}})
    end
  end

  describe '#prepare_document_batch' do
    let(:document_batch) {
      [
          {'id' => 1, 'field' => 'value'},
          {'id' => 1, 'field' => 'other_value'}
      ]
    }

    it 'should call convert_to_json on indexer' do
      expect_any_instance_of(AgnosticBackend::Cloudsearch::Indexer).to receive(:convert_to_json).with(document_batch).and_call_original
      expect(subject.send(:prepare_document_batch, document_batch: document_batch)).to be_a String
    end
  end

  describe '#split_count' do
    context 'when document size is smaller max_document_size' do
      it 'should return 1' do
        allow(subject).to receive(:max_document_size).and_return(10.0)
        expect(subject.send(:split_count, document_size: 5)).to eq 1
      end
    end

    context 'when document size exceeds max_document_size' do
      it 'should return division result round up' do
        allow(subject).to receive(:max_document_size).and_return(10.0)
        expect(subject.send(:split_count, document_size: 32)).to eq 4
      end
    end
  end

  describe '#split_in_document_batches' do
    let(:document_batch) {
      [
          {'id' => 1, 'field' => 'value'},
          {'id' => 1, 'field' => 'other_value'}
      ]
    }

    let(:document_batch_json) {
      document_batch.to_json
    }

    before do
      allow_any_instance_of(AgnosticBackend::Cloudsearch::Indexer).to receive(:convert_to_json).with(document_batch).and_return document_batch_json
    end

    it 'should calculate the document size in json format' do
      expect(document_batch_json).to receive(:bytesize).and_return 5
      subject.send(:split_in_document_batches, batch: document_batch)
    end

    it 'should split the batch accordingly' do
      allow(subject).to receive(:max_document_size).and_return(11.0)
      expect(document_batch_json).to receive(:bytesize).and_return 20
      expect(document_batch).to receive(:in_groups).with(2, false)
      subject.send(:split_in_document_batches, batch: document_batch)
    end

    it 'should return an array of batches with appropriate size' do
      allow(subject).to receive(:max_document_size).and_return(11.0)
      expect(document_batch_json).to receive(:bytesize).and_return 20
      expect(subject.send(:split_in_document_batches, batch: document_batch)).to eq([
                                                                                        [document_batch.first],
                                                                                        [document_batch.last]
                                                                                    ])
    end
  end

  describe '#batch_for' do
    let(:indexable_1) { double('Indexable') }
    let(:indexable_2) { double('Indexable') }
    let(:group) { [indexable_1, indexable_2] }

    before do
      expect(indexable_1).to receive(:generate_document).and_return({'id' => 1, 'field' => 'value'})
      expect(indexable_2).to receive(:generate_document).and_return({'id' => 2, 'field' => 'other_value'})
    end

    it 'should generate a list of documents created from indexables' do

      expect(subject.send(:batch_for, group: group)).to eq [
                                                               {'type'=>'add', 'id'=>'1', 'fields'=>{'id'=>1, 'field'=>'value'}},
                                                               {'type'=>'add', 'id'=>'2', 'fields'=>{'id'=>2, 'field'=>'other_value'}}
                                                           ]
    end
  end

  describe '#process_document_batch' do
    let(:document_batch) {
      [
          {'id' => 1, 'field' => 'value'},
          {'id' => 2, 'field' => 'other_value'}
      ]
    }
    it 'should foo' do
      document_batch_json = "[{\"id\":1,\"field\":\"value\"},{\"id\":2,\"field\":\"other_value\"}]"
      expect(subject).to receive(:publish_document).with(document: document_batch_json)
      expect(subject.send(:process_document_batch, document_batch: document_batch))
    end
  end
end
