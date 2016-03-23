require 'spec_helper'
require 'webmock/rspec'

describe AgnosticBackend::Elasticsearch::Indexer do
  let(:index_class) { class DummyClass;end }
  let(:index) { AgnosticBackend::Elasticsearch::Index.new(index_class) }
  subject { AgnosticBackend::Elasticsearch::Indexer.new(index) }

  it { expect(subject).to be_a(AgnosticBackend::Indexer) }
  it { expect(subject.index).to eq(index) }

  describe "#publish" do
    context "when document has an id" do
      let(:document) do
        {
          id: 1,
          title: "title",
          text:  "text",
          date_created:  "date"
        }
      end


      before do
        index_response = {"_index"=>"index", 
                          "_type"=>"type", "_id"=>"AVOPav44RRb-B-7BHyCn", 
                          "_version"=>1, 
                          "created"=>true}
        stub_request(:put, 'http://localhost:9200/index/type/1')
          .with(body: hash_including(title: 'title',
        text: 'text',
        date_created: 'date'))
          .to_return(status: 201, body: JSON.generate(index_response))
      end

      it 'should index a document to elastic search' do
        expect(subject.publish(document)).to be_true
      end
    end
    context "when document does not have an id" do
      let(:document) do
        {
          title: "title",
          text:  "text",
          date_created:  "date"
        }
      end

      before do
        index_response = {"_index"=>"index", 
                          "_type"=>"type", "_id"=>"1", 
                          "_version"=>1, 
                          "created"=>true}
        stub_request(:post, 'http://localhost:9200/index/type/')
          .with(body: hash_including(title: 'title',
        text: 'text',
        date_created: 'date'))
          .to_return(status: 201, body: JSON.generate(index_response))
      end

      it 'should index a document to elastic search' do
        expect(subject.publish(document)).to be true
      end

    end

  end
end
