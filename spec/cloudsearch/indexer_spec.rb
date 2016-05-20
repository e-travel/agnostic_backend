require "spec_helper"

describe AgnosticBackend::Cloudsearch::Indexer do
  let(:index_name) { 'dummies' }
  let(:index_class) { class DummyClass; end }
  let(:index) { AgnosticBackend::Cloudsearch::Index.new(index_class) }

  before { allow_any_instance_of(AgnosticBackend::Cloudsearch::Index).to receive(:parse_option) }

  subject do
    AgnosticBackend::Cloudsearch::Indexer.new(index)
  end

  it { expect(subject).to be_a_kind_of(AgnosticBackend::Indexer) }

  describe '#publish' do
    let(:client) { double("CloudSearchClient") }
    let(:document) { double("Document") }
    let(:response) { double("Response") }

    it "should use the aws gem to upload the documents" do
      expect(client).to receive(:upload_documents).
                         with(documents: document, content_type:'application/json').
                         and_return(response)
      expect(subject).to receive(:client).and_return(client)

      subject.publish(document)
    end

    it 'should handle the response' do
      allow(subject).to receive(:client).and_return(client)
      allow(client).to receive(:upload_documents).and_return(response)
      expect(subject.publish(document)).to eq response
    end

  end

  describe "#delete" do
    let(:client) { double("CloudSearchClient") }
    let(:document_ids) { [1, 2] }
    let(:response) { double("Response") }
    let(:document) { "[{\"type\":\"delete\",\"id\":[1,2]}]" }

    it "should use the aws gem to upload the documents" do
      expect(client).to receive(:upload_documents).
                            with(documents: document, content_type:'application/json').
                            and_return(response)
      expect(subject).to receive(:client).and_return(client)

      subject.delete(document_ids)
    end
  end

  describe '#client' do
    let(:client) { double("Client") }
    it 'should return a client configured with the document endpoint' do
      expect(subject.index).
        to receive(:cloudsearch_domain_client).and_return client
      expect(subject.send(:client)).to eq client
    end
  end

  describe '#prepare' do
    let(:document) { {"id" => 1} }
    it { expect(subject.send(:prepare, document)).to eq document }
  end

  describe '#transform' do
    let(:document) do
      {
        a: 1,
        b: 2,
        c: false
      }
    end
    context 'when the supplied document is empty' do
      it 'should return an empty document' do
        expect(subject.send(:transform, {})).to be_empty
      end
    end

    it "should flatten document" do
      expect(subject).to receive(:flatten).with(document).and_call_original
      expect(subject.send(:transform, document))
    end

    it "should reject nil values form document" do
      expect(subject).to receive(:reject_blank_values_from).
                          with(subject.send(:flatten, document)).and_call_original

      expect(subject.send(:transform, document))
    end

    it "should convert bool values to string" do
      expect(subject).to receive(:convert_bool_values_to_string_in).
                             with(subject.send(:reject_blank_values_from, subject.send(:flatten, document))).
                             and_call_original

      expect(subject.send(:transform, document))
    end

    it "should add metadata to document" do
      expect(subject).to receive(:add_metadata_to).and_call_original
      expect(subject.send(:transform, document))
    end

    it "should convert to json" do
      expect(subject).to receive(:convert_to_json).and_call_original

      expect(subject.send(:transform, document))
    end

    it "should return a json object" do
      json_obj = ActiveSupport::JSON.encode([{id: "1", type: "some type"}])

      expect(subject).to receive(:convert_to_json).and_return(json_obj)

      result = subject.send(:transform, document)
      expect(result).to eq(json_obj)
    end
  end

  describe "#flatten" do

    context 'when the supplied document is flat' do
      let(:document) { { a: 1, b: 2, c: 3} }

      it 'should return the same document with keys as strings' do
        expect(subject.send(:flatten, document)).to eq({ "a" => 1,  "b" => 2, "c" => 3 })
      end
    end

    context 'when the supplied document is nested' do
      let(:nested_document) do
        {
          a: {
            b: {
              c: "a__b__c"
            },
            d: {
              e: "a__d__e"
            },
            f: "a__f"
          },
          h: "h"
        }
      end

      it 'should convert the document to flat document' do
        expect(subject.send(:flatten, nested_document)).to eq({
                                                                "a__b__c" => "a__b__c",
                                                                "a__d__e" => "a__d__e",
                                                                "a__f" => "a__f",
                                                                "h" => "h"
                                                              })
      end
    end
  end

  describe "#reject_nil_values" do

    context 'when the supplied document contains null values' do
      let(:document) { { a: 1, b: 2, c: nil} }
      it 'should exclude the null values' do
        expect(subject.send(:reject_blank_values_from, document)).to eq( { a: 1, b: 2 } )
      end

      context "when hash contains string keys" do
        let(:document) { { "d" => nil, a: 1, "b" => 2, c: nil} }
        it 'should exclude the null values' do
          expect(subject.send(:reject_blank_values_from, document)).to eq( { a: 1, "b" => 2 } )
        end
      end
    end
  end

  describe "#date_format" do
    # flatten
    # reject nil values
    # convert bool to string
    ## date_format

    let(:two_days_ago) { 2.days.ago }
    let(:one_day_ago) { 1.day.ago }
    let(:document) do
      {
        id: 123456789,
        type: "Task",
        created_at: two_days_ago,
        closed_at: one_day_ago,
        closed_by: 123,
        notes: ["note 1", "note 2", "note 3", "note 4"],
        proceed_anyway: "true",
        extra_refund_amount: 2015.1515,
        needs_baggage_limit_info: "false",
        contract_number: "AZ123456789"
      }
    end

    it "should translate document date to RFC3339 format" do
      translated_doc = subject.send(:date_format, document)

      expect(translated_doc).to eq({id: 123456789,
                                    type: "Task",
                                    created_at: two_days_ago.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
                                    closed_at: 1.day.ago.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
                                    closed_by: 123,
                                    notes: ["note 1", "note 2", "note 3", "note 4"],
                                    proceed_anyway: "true",
                                    extra_refund_amount: 2015.1515,
                                    needs_baggage_limit_info: "false",
                                    contract_number: "AZ123456789"
                                   })
    end
  end

  describe "#convert_bool_values_to_string_in" do
    let(:doc) do
      {
        type: "document",
        id: 1,
        amount: 2015.222,
        title: "this is a string",
        is_document: true,
        is_task: false,
        categories: ["1", "2", "3", "4"]
      }
    end

    it "should change boolean values to strings" do
      result = subject.send(:convert_bool_values_to_string_in, doc)

      expect(result).to eq({type: "document",
                            id: 1,
                            amount: 2015.222,
                            title: "this is a string",
                            is_document: "true",
                            is_task: "false",
                            categories: ["1", "2", "3", "4"]
                           })
    end

  end

  describe "#add_metadata_to" do
    let(:document) do
      {
        "id" => 1,
        a: "a",
        b: "b",
        c: "c"
      }
    end

    it "should return a hash with cloudsearch metadata ready to converted to json" do
      result = subject.send(:add_metadata_to, document)

      expect(result).to eq({
                             "type" => "add",
                             "id" => "1",
                             "fields" => document,
                           })
    end
  end

  describe "#convert_to_json" do
    let(:transformed_document) do
      {
        "type" => "add",
        "id" => "123456789",
        "fields" => {
          title: "The seeker: THe Dark is Rising",
          gendres: ["Adventure","Drama","Fantasy","Thriller"],
          is_published: "yes"
        }
      }
    end

    it "should return an array json object" do
      result = subject.send(:convert_to_json, transformed_document)

      expect(result).to eq(
                          "{\"type\":\"add\",\"id\":\"123456789\",\"fields\":{\"title\":\"The seeker: THe Dark is Rising\",\"gendres\":[\"Adventure\",\"Drama\",\"Fantasy\",\"Thriller\"],\"is_published\":\"yes\"}}"
                        )
    end
  end

end
