require 'spec_helper'

describe AgnosticStore::Indexer do

  subject do
    index_class = Class.new
    index = AgnosticStore::Index.new(index_class)

    AgnosticStore::Indexer.new(index)
  end

  it { expect(subject).to respond_to :index }

  describe '#put' do

    let(:indexable) { double('Indexable') }
    let(:document) { double('Document') }

    before { allow(indexable).to receive(:generate_document).and_return document }

    before do
      expect(subject).to receive(:prepare).with(document).and_return(document)
      expect(subject).to receive(:transform).with(document).and_return(document)
    end

    context 'when indexing is successful' do
      it 'should return true' do
        expect(subject).to receive(:publish).with(document)
        expect(subject.put(indexable)).to be_true
      end
    end

    context 'when indexing is not successful' do
      it 'should return false' do
        expect(subject).to receive(:publish).with(document).and_raise('boom')
        expect(subject.put(indexable)).to be_false
      end
    end

  end

  describe '#delete' do
    it 'should be abstract' do
      expect { subject.delete 'document' }.to raise_error NotImplementedError
    end
  end

  describe '#publish' do
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
