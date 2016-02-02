require 'spec_helper'

describe AgnosticStore::Index do
  let(:index_name) { :tasks }
  let(:indexable_class) { double('IndexableClass') }

  subject do
    AgnosticStore::Index.new(indexable_class)
  end

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
end
