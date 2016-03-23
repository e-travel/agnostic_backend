require 'spec_helper'

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
      end
      define_index_notifier { self }
    end

    AgnosticBackend::Indexable::Config.configure_index(
      IndexableClass,
      AgnosticBackend::Elasticsearch::Index)
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
    it { expect(subject.elastic_search_client).to be_a AgnosticBackend::Elasticsearch::Client }
  end
  
  describe "#query_builder" do
    pending
  end
end
