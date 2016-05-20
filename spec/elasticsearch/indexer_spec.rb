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

  let(:index) { ESIndexableObject.create_index }
  subject { index.indexer }

  it { expect(subject).to be_a(AgnosticBackend::Indexer) }
  it { expect(subject.index).to eq(index) }
  it { expect(subject.index.type).to be_present }
  it { expect(subject.index.index_name).to be_present }

  describe "#publish" do
    context "when document has an id" do
      let(:document) do
        {
          "id" => 1,
          "title" => "title",
          "text" =>  "text",
          "date_created" =>  "10/2/1988"
        }
      end


      before do
        index_response = {"_index"=>"index",
                          "_type"=>"type", "_id"=>"AVOPav44RRb-B-7BHyCn",
                          "_version"=>1,
                          "created"=>true}
        stub_request(:put, 'http://localhost:9200/index/type/1')
          .with(body: hash_including(id: 1, title: 'title', text: 'text', date_created: '10/2/1988'))
          .to_return(status: 201, body: JSON.generate(index_response))
      end

      it 'should index a document to elastic search' do
        response = subject.publish(document)
        expect(response.status).to eq(201)
      end
    end
    context "when document does not have an id" do
      let(:document) do
        {
          "title" => "title",
          "text" =>  "text",
          "date_created" =>  "date"
        }
      end

      before do
        index_response = {"_index"=>"index",
                          "_type"=>"type", "_id"=>"1",
                          "_version"=>1,
                          "created"=>true}
        stub_request(:post, 'http://localhost:9200/index/type')
          .with(body: hash_including("title" => 'title', "text" => 'text', "date_created" => 'date'))
          .to_return(status: 201, body: JSON.generate(index_response))
      end

      it 'should index a document to elastic search' do
        response = subject.publish(document)
        expect(response.status).to eq 201
      end
    end
  end
end
