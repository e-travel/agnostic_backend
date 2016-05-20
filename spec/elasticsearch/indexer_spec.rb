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
      subject.publish(document)
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
end
