require 'spec_helper'

describe AgnosticBackend::Elasticsearch::Index do

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

  let(:es_mappings) {
    {"_all"=>{"enabled"=>false},
     "properties"=>{
       "id"=>{"type"=>"integer", "index"=>"not_analyzed"},
       "a_string"=>{"type"=>"string", "index"=>"not_analyzed"},
       "a_string_array"=>{"type"=>"string", "index"=>"not_analyzed"},
       "a_double"=>{"type"=>"double", "index"=>"not_analyzed"},
       "a_boolean"=>{"type"=>"boolean", "index"=>"not_analyzed"},
       "a_text"=>{"type"=>"string"},
       "a_text_array"=>{"type"=>"string"}
     }
    }
  }

  subject { ESIndexableObject.create_index }

  it { should be_a AgnosticBackend::Index }
  it { should be_a AgnosticBackend::Elasticsearch::Index }

  describe "#indexer" do
    it { expect(subject.indexer).to be_a AgnosticBackend::Indexer }
    it { expect(subject.indexer).to be_a AgnosticBackend::Elasticsearch::Indexer }
  end

  describe "#schema" do
    it 'should request the schema' do
      expect(ESIndexableObject).to receive(:schema).and_call_original
      schema = subject.schema
      expect(schema.all?{|_, f_type| f_type.is_a? AgnosticBackend::Indexable::FieldType} ).to be true
    end
  end

  describe "#client" do
    it { expect(subject.client).to be_a AgnosticBackend::Elasticsearch::Client }
  end

  describe "#query_builder" do
    it { expect(subject.query_builder).to be_a AgnosticBackend::Queryable::Elasticsearch::QueryBuilder }
  end

  describe '#configure' do
    it 'should flatten the schema' do
      allow(subject).to receive(:indexer).and_return(subject.indexer)
      allow(subject.client).to receive(:send_request)
      expect(subject.indexer).to receive(:flatten).with(subject.schema).and_call_original
      subject.configure
    end
    it 'should make the appropriate request to ES' do
      allow(subject).to receive(:client).and_return(subject.client)
      expect(subject.client).to receive(:send_request).with(:put,
                                                            {path: "index/_mapping/type",
                                                             body: es_mappings})
      subject.configure
    end
  end

  describe '#create' do
    it 'should make the appropriate request to ES' do
      allow(subject).to receive(:client).and_return(subject.client)
      expect(subject.client).to receive(:send_request).with(:put,
                                                            {path: 'index'})
      subject.create
    end
  end

  describe '#destroy!' do
    it 'should make the appropriate request to ES' do
      allow(subject).to receive(:client).and_return(subject.client)
      expect(subject.client).to receive(:send_request).with(:delete,
                                                            {path: 'index'})
      subject.destroy!
    end
  end

  describe '#exists?' do
    let(:response) { double("Response") }
    before { allow(subject).to receive(:client).and_return(subject.client) }
    it 'should make the appropriate request to ES' do
      allow(response).to receive(:success?)
      expect(subject.client).
        to receive(:send_request).with(:head, {path: 'index'}).
            and_return(response)
      subject.exists?
    end

    context 'when ES response is successful' do
      before { allow(response).to receive(:success?).and_return true }
      it 'should return true' do
        expect(subject.client).to receive(:send_request).and_return(response)
        expect(subject).to exist
      end
    end
    context 'when ES response is not successful' do
      before { allow(response).to receive(:success?).and_return false }
      it 'should return false' do
        expect(subject.client).to receive(:send_request).and_return(response)
        expect(subject).not_to exist
      end
    end
  end

  describe '#mappings' do
    let(:flat_schema) { subject.indexer.flatten(subject.schema) }
    it 'should map the schema to an ES payload' do
      expect(subject.send(:mappings, flat_schema)).to eq es_mappings
    end
  end

end
