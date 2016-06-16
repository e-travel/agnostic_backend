require 'spec_helper'

describe AgnosticBackend::Indexer do

  before { allow_any_instance_of(AgnosticBackend::Index).to receive(:parse_options) }

  subject do
    index_class = Class.new
    index = AgnosticBackend::Index.new(index_class)

    AgnosticBackend::Indexer.new(index)
  end

  it { expect(subject).to respond_to :index }

  describe '#put' do
    let(:indexable) { double('Indexable') }
    it 'should forward to #put_all and return its value' do
      expect(subject).to receive(:put_all).with([indexable]).and_return 'result'
      expect(subject.put(indexable)).to eq 'result'
    end
  end

  describe '#put_all' do
    let(:document) { {a: 1} }
    let(:empty_document) { {} }
    let(:indexable1) { double("Indexable1", generate_document: document) }
    let(:indexable2) { double("Indexable2", generate_document: empty_document) }

    before do
      expect(subject).to receive(:prepare).twice {|doc| doc}
      expect(subject).to receive(:transform).twice {|doc| doc}
    end

    context 'when at least one document is non-empty' do
      it 'should publish the non-empty documents' do
        expect(subject).to receive(:publish_all).with([document]).and_return 'result'
        expect(subject.put_all([indexable1, indexable2])).to eq 'result'
      end
    end

    context 'when all documents are empty' do
      it 'should not publish any documents' do
        expect(subject).not_to receive(:publish_all)
        expect(subject.put_all([indexable2, indexable2])).to be_nil
      end
    end
  end

  describe '#delete' do
    let(:document_id) { 1 }
    it 'should forward to #delete_all and return its value' do
      expect(subject).to receive(:delete_all).with([document_id]).and_return 'result'
      expect(subject.delete document_id).to eq 'result'
    end
  end

  describe '#delete_all' do
    it 'should be abstract' do
      expect { subject.delete_all [] }.to raise_error NotImplementedError
    end
  end

  describe '#publish' do
    let(:document) { double("Document") }
    it 'should forward to #publish_all and return its value' do
      expect(subject).to receive(:publish_all).with([document]).and_return 'result'
      expect(subject.send(:publish, document)).to eq 'result'
    end
  end

  describe '#publish_all' do
    it 'should be abstract' do
      expect { subject.send(:publish, 'document') }.to raise_error NotImplementedError
    end
  end

  describe '#transform' do
    it 'should be abstract' do
      expect { subject.send(:transform,'document') }.to raise_error NotImplementedError
    end
  end

  describe '#prepare' do
    it 'should be abstract' do
      expect { subject.send(:prepare, 'document') }.to raise_error NotImplementedError
    end
  end
end
