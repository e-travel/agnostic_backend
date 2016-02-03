require 'spec_helper'

describe AgnosticBackend::Indexable::Config do
  subject { AgnosticBackend::Indexable::Config }

  let(:index_class) { double('IndexClass') }
  let(:indexable_class) { double('IndexableClass', name:'IndexableClass') }
  let(:options) { {a: 'A'} }

  describe '.configure_index' do
    it 'should configure the index' do
      subject.configure_index(indexable_class, index_class, **options)
      entry = subject.indices[indexable_class.name]
      expect(entry.index_class).to eq index_class
      expect(entry.options).to eq options
    end
  end

  describe '.create_index_for' do
    before { subject.configure_index(indexable_class, index_class)}
    it 'should create a new Index' do
      expect(index_class).to receive(:new).with(indexable_class, {})
      subject.create_index_for(indexable_class)
    end
  end
end
