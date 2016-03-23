require 'spec_helper'
require 'webmock/rspec'

describe AgnosticBackend::Elasticsearch::Index do
  before do
    class IndexableClass
      include AgnosticBackend::Indexable
      define_index_fields do
        integer :id
        string :a_string
        double :a_double
        boolean :a_boolean
        text :a_text
        text_array :a_text_array
        date :a_date
        boolean :a_boolean
      end
      define_index_notifier { self }
    end

    AgnosticBackend::Indexable::Config.configure_index(
      IndexableClass,
      AgnosticBackend::Elasticsearch::Index, endpoint: 'http://localhost:9200', index_name: 'index', type: 'type')
  end

  subject { IndexableClass.create_index }

  it { should be_a AgnosticBackend::Index }
  it { should be_a AgnosticBackend::Elasticsearch::Index }

  describe "#indexer" do
    it { expect(subject.indexer).to be_a AgnosticBackend::Indexer }
    it { expect(subject.indexer).to be_a AgnosticBackend::Elasticsearch::Indexer }
  end

  describe "#schema" do
    it 'should request the schema' do
      expect(IndexableClass).to receive(:schema).and_call_original
      schema = subject.schema
      expect(schema.all?{|_, f_type| f_type.is_a? AgnosticBackend::Indexable::FieldType} ).to be true
    end
  end

  describe "#elastic_search_client" do
    it { expect(subject.elasticsearch_client).to be_a AgnosticBackend::Elasticsearch::Client }
  end
  
  describe "#query_builder" do
    pending
  end
 
  describe "#create_index" do
    it 'should create an index' do
      stub_request(:put, "http://localhost:9200/index").with(body: nil).to_return(status: 201, body: JSON.generate({a: "response"}))
      subject.create_index
    end
  end

  describe "#configure" do
   it 'should configure mappings to ES' do
     index_response = { "acknowledged" => true }

     subject.schema.each do |fname, ftype|
       es_index_type = AgnosticBackend::Elasticsearch::IndexField.new(fname, ftype)
       stub_request(:put, "http://localhost:9200/index/_mapping/type").
         with(:body => "{\"properties\":{\"#{es_index_type.name}\":{\"type\":\"#{es_index_type.elasticsearch_type}\",\"index\":\"not_analyzed\"}}}").to_return(status: 201, body: JSON.generate(index_response))
     end

     subject.configure
    end
  end

end
