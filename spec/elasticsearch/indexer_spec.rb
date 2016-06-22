require 'spec_helper'
require 'webmock/rspec'

describe AgnosticBackend::Elasticsearch::Indexer do

  let(:field_block) do
    proc {
      integer :id
      string :a_string
      string_array :a_string_array
      double :a_double
      boolean :a_boolean
      text :a_text
      text_array :a_text_array
    }
  end

  before do
    Object.send(:remove_const, :ESIndexableObject) if Object.constants.include? :ESIndexableObject
    class ESIndexableObject; end
    ESIndexableObject.send(:include, AgnosticBackend::Indexable)
    ESIndexableObject.define_index_fields &field_block

    if AgnosticBackend::Indexable::Config.indices[ESIndexableObject.name].nil?
      AgnosticBackend::Indexable::Config.configure_index(
        ESIndexableObject,
        AgnosticBackend::Elasticsearch::Index,
        endpoint: 'http://localhost:9200',
        index_name: 'index',
        type: 'type')
    end
  end

  let(:document) do
    {
      "id" => 1,
      "title" => "title",
      "text" =>  "text",
      "date_created" =>  "10/2/1988"
    }
  end

  let(:index) { ESIndexableObject.create_index }
  subject { index.indexer }

  it { expect(subject).to be_a(AgnosticBackend::Indexer) }
  it { expect(subject.index).to eq(index) }
  it { expect(subject.index.type).to be_present }
  it { expect(subject.index.index_name).to be_present }

  describe "#publish" do
    let(:client) { subject.send(:client) }
    before { allow(subject).to receive(:client).and_return(client) }

    it 'should make the appropriate request to ES' do
      expect(client).to receive(:send_request).with(:put,
                                                    path: "/index/type/1",
                                                    body: document)
      subject.send(:publish, document)
    end
  end

  describe '#publish_all' do
    let(:other_document) do
      {
        "id" => 2,
        "title" => "Another title",
        "text" =>  "Another text",
        "date_created" =>  "10/3/1988"
      }
    end
    let(:client) { subject.send(:client) }
    before { allow(subject).to receive(:client).and_return(client) }

    it 'should convert the data to a string' do
      allow(client).to receive(:send_request)
      expect(subject).to receive(:convert_to_bulk_upload_string).with([document, other_document])
      subject.send(:publish_all, [document, other_document])
    end

    it 'should make an appopriate request to ES' do
      allow(subject).to receive(:convert_to_bulk_upload_string).and_return 'hello'
      expect(client).to receive(:send_request).with(:post,
                                                    path: "/index/type/_bulk",
                                                    body: 'hello')
      subject.send(:publish_all, [document])
    end

    it 'should raise an error if at least one of the docs fails to be indexed' do
      response = double("Response", body: {"errors" => true}.to_json)
      allow(subject).to receive(:convert_to_bulk_upload_string).and_return 'hello'
      expect(client).to receive(:send_request).with(:post,
                                                    path: "/index/type/_bulk",
                                                    body: 'hello').
                         and_return response
      expect { subject.send(:publish_all, [document]) }.to raise_error AgnosticBackend::IndexingError
    end
  end

  describe '#prepare' do
    it 'should return the document as is' do
      expect(subject.send(:prepare, document)).to eq document
    end

    context 'when document does not have an id key' do
      let(:document) { {} }
      it 'should raise an error' do
        expect{ subject.send(:prepare, document) }.to raise_error AgnosticBackend::IndexingError
      end
    end
  end

  describe '#convert_to_bulk_upload_string' do
    it 'should convert the array of hashes to the ES bulk upload format' do
      other_document = {
        "id" => 2,
        "title" => "Another title",
        "text" =>  "Another text",
        "date_created" =>  "10/3/1988"
      }
      formatted_string = <<-JSON
{"index":{"_id":1}}
{"id":1,"title":"title","text":"text","date_created":"10/2/1988"}

{"index":{"_id":2}}
{"id":2,"title":"Another title","text":"Another text","date_created":"10/3/1988"}
JSON

      fmt = subject.send(:convert_to_bulk_upload_string, [document, other_document])
      expect(fmt).to eq formatted_string
    end

    it 'should apply the preparation/transformation chain to each document' do
      transformed_document = subject.send(:transform, document)
      expect(subject).to receive(:transform).with(document).and_call_original
      expect(subject).to receive(:prepare).with(transformed_document).and_call_original
      subject.send(:convert_to_bulk_upload_string, [document])
    end
  end
end
