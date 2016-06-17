require 'spec_helper'

describe AgnosticBackend::Indexable::Config::Entry do
  let(:index_class) { double('IndexClass') }
  let(:indexable_class) { double('IndexableClass', name:'IndexableClass') }
  let(:index_options) { {a: 'A'} }

  subject { AgnosticBackend::Indexable::Config::Entry.new index_class: index_class,
                                                          indexable_class: indexable_class,
                                                          primary: true,
                                                          **index_options }

  it { expect(subject).to respond_to :index_class }
  it { expect(subject.options).to eq index_options }

  it { expect(subject).to be_primary }

  describe '#create_index' do
    it 'should create and return a new index' do
      expect(index_class).
        to receive(:new).
            with(indexable_class, primary: true, **index_options).
            and_return 'Result'
      expect(subject.create_index).to eq 'Result'
    end
  end
end

describe AgnosticBackend::Indexable::Config do
  subject { AgnosticBackend::Indexable::Config }

  let(:index_class) { double('IndexClass') }
  let(:indexable_class) { double('IndexableClass', name:'IndexableClass') }
  let(:index_options) { {a: 'A'} }

  let(:secondary_index_class) { double('SecondaryIndexClass') }
  let(:secondary_index_options) { {b: 'B'} }

  describe '.configure_index' do
    it 'should configure the index' do
      subject.configure_index(indexable_class, index_class, **index_options)
      entry = subject.indices[indexable_class.name].first
      expect(entry.index_class).to eq index_class
      expect(entry).to be_primary
      expect(entry.options).to eq index_options
    end
  end

  describe '.configure_secondary_index' do

    context 'when primary index does not exist' do
      before { subject.indices.delete indexable_class.name }
      it 'should raise an error' do
        expect do
          subject.configure_secondary_index(indexable_class,
                                            secondary_index_class,
                                            **secondary_index_options)
        end.to raise_error(/No primary index exists/)
      end
    end

    context 'when primary index exists' do
      before { subject.configure_index(indexable_class, index_class, **index_options) }
      it 'should configure the secondary index' do
        subject.configure_secondary_index(indexable_class,
                                          secondary_index_class,
                                          **secondary_index_options)
        entries = subject.indices[indexable_class.name]
        expect(entries.size).to eq 2
        expect(entries.first.index_class).to eq index_class
        expect(entries.last.index_class).to eq secondary_index_class
        expect(entries.last).not_to be_primary
        expect(entries.last.options).to eq secondary_index_options
      end
    end
  end

  describe '.create_index_for' do
    before { subject.configure_index(indexable_class, index_class)}
    let(:entry) { subject.indices[indexable_class.name].first }
    it 'should create a new (primary) Index' do
      expect(entry).to receive(:create_index)
      subject.create_index_for(indexable_class)
    end
  end

  describe '.create_indices_for' do
    let(:entries) { subject.indices[indexable_class.name] }
    let(:primary_index) { double("PrimaryIndex") }
    let(:secondary_index) { double("SecondaryIndex") }

    before do
      subject.configure_index(indexable_class, index_class)
      subject.configure_secondary_index(indexable_class,
                                        secondary_index_class,
                                        **secondary_index_options)
      allow(primary_index).to receive(:primary?).and_return true
      allow(secondary_index).to receive(:primary?).and_return false

      expect(entries.first).to receive(:create_index).and_return primary_index
      expect(entries.last).to receive(:create_index).and_return secondary_index
    end

    context 'when include_primary is false' do
      it 'should return an array of indices that does not include the primary index' do
        indices = subject.create_indices_for(indexable_class, include_primary: false)
        expect(indices.length).to eq 1
        expect(indices.first).to eq secondary_index
      end
    end

    context 'when include_primary is true' do
      it 'should return an array of indices that includes the primary index' do
        indices = subject.create_indices_for(indexable_class)
        expect(indices.length).to eq 2
        expect(indices.first).to eq primary_index
        expect(indices.last).to eq secondary_index
      end
    end
  end
end
