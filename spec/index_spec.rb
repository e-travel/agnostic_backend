require 'spec_helper'

describe AgnosticBackend::Index do
  let(:index_name) { :tasks }
  let(:indexable_class) { double('IndexableClass') }

  before { expect_any_instance_of(AgnosticBackend::Index).to receive(:parse_options) }

  subject { AgnosticBackend::Index.new(indexable_class) }

  it { expect(subject).to respond_to :options }

  it { expect(subject).to be_primary }

  describe '#indexer' do
    it 'should be abstract' do
      expect { subject.indexer }.to raise_error NotImplementedError
    end
  end

  describe '#configure' do
    it 'should be abstract' do
      expect { subject.configure }.to raise_error NotImplementedError
    end
  end

  describe '#parse_options' do
    before { allow_any_instance_of(AgnosticBackend::Index).to receive(:parse_options).and_call_original }
    it 'should be abstract' do
      expect { subject.parse_options }.to raise_error NotImplementedError
    end
  end

  describe '#name' do
    it 'should return index name for indexable class' do
      name = double('Name')
      expect(indexable_class).to receive(:index_name).and_return(name)
      expect(subject.name).to eq name
    end
  end

  describe '#schema' do
    it 'should return schema for indexable class' do
      schema = double('Schema')
      expect(indexable_class).to receive(:schema).and_return(schema)
      expect(subject.schema).to eq schema
    end
  end

  describe '#parse_option' do
    let(:options) { { a: 1 } }
    context 'when option_name is included in options as a key' do
      before { allow(subject).to receive(:options).and_return options }
      it 'should return its value' do
        expect(subject.send(:parse_option, :a)).to eq 1
      end
    end
    context 'when option_name is not included in options as a key' do
      it 'should raise an Exception' do
        expect{subject.send(:parse_option, :b)}.to raise_error "b must be specified"
      end
    end
    context 'when option is optional and does not exist in options' do
      it 'should return the default value' do
        expect(subject.send(:parse_option, :b, optional: true, default: 2)).to eq 2
      end
    end
  end

end
