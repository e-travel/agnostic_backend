require "spec_helper"

describe AgnosticBackend::Cloudsearch::Indexer do
  let(:index_name) { 'dummies' }
  let(:index_class) { class DummyClass; end }
  let(:index) { AgnosticBackend::Cloudsearch::Index.new(index_class) }

  before { allow_any_instance_of(AgnosticBackend::Cloudsearch::Index).to receive(:parse_option) }

  subject { AgnosticBackend::Cloudsearch::Indexer.new(index) }

  it { expect(subject).to be_a_kind_of(AgnosticBackend::Indexer) }

  describe '#publish' do
    let(:document) { double("Document") }
    it 'should forward to #publish_all and return its value' do
      expect(subject).to receive(:publish_all).with([document]).and_return 'result'
      expect(subject.send(:publish, document)).to eq 'result'
    end
  end

  describe '#publish_all' do
    let(:client) { double("CloudSearchClient") }
    let(:document) { {a: 1} }

    it 'should do nothing if no documents are provided' do
      expect(subject).not_to receive(:with_exponential_backoff)
      expect(subject.send(:publish_all, [])).to be_nil
    end

    it 'should raise an error if the payload exceeds the cloudsearch limit' do
      expect(subject).to receive(:payload_too_heavy?).and_return true
      expect { subject.send(:publish_all, [document]) }.
        to raise_error AgnosticBackend::Cloudsearch::PayloadLimitExceededError
    end

    it "should use the aws gem to upload the documents and return the response" do
      expect(subject).to receive(:client).and_return(client)
      expect(subject).to receive(:with_exponential_backoff).and_call_original
      expect(client).to receive(:upload_documents).
                         with(documents: ActiveSupport::JSON.encode([document]),
                              content_type:'application/json').
                         and_return('result')
      expect(subject.send(:publish_all, [document])).to eq 'result'
    end
  end

  describe "#delete" do
    let(:document_id) { 1 }
    it 'should forward to #delete_all and return its value' do
      expect(subject).to receive(:delete_all).with([document_id]).and_return 'result'
      expect(subject.delete(document_id)).to eq 'result'
    end
  end

  describe "#delete_all" do
    it 'forward to #publish_all and return its value' do
      expect(subject).
        to receive(:publish_all).
            with([{'type'=>'delete', 'id'=>1},{'type'=>'delete', 'id'=>2}]).
            and_return 'result'
      expect(subject.delete_all([1,2])).to eq 'result'
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

    context 'when the document has no id field' do
      let(:document) { {"a" => 1} }
      it { expect {subject.send(:prepare, document)}.to raise_error(/Document does not have an ID field/)}
    end
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
        other_dates: [one_day_ago, two_days_ago],
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
                                    closed_at: one_day_ago.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
                                    other_dates: [one_day_ago.utc.strftime("%Y-%m-%dT%H:%M:%SZ"), two_days_ago.utc.strftime("%Y-%m-%dT%H:%M:%SZ")],
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

  describe '#payload_too_heavy?' do
    let(:payload) { 'a' * size }
    context 'when payload is larger than the hardcoded value' do
      let(:size) { AgnosticBackend::Cloudsearch::Indexer::MAX_PAYLOAD_SIZE_IN_BYTES + 1 }
      it { expect(subject.send(:payload_too_heavy?, payload)).to be true }
    end
    context 'when payload is less than the hardcoded value' do
      let(:size) { AgnosticBackend::Cloudsearch::Indexer::MAX_PAYLOAD_SIZE_IN_BYTES - 1 }
      it { expect(subject.send(:payload_too_heavy?, payload)).to be false }
    end
    context 'when payload is equal the hardcoded value' do
      let(:size) { AgnosticBackend::Cloudsearch::Indexer::MAX_PAYLOAD_SIZE_IN_BYTES }
      it { expect(subject.send(:payload_too_heavy?, payload)).to be false }
    end

  end

end
