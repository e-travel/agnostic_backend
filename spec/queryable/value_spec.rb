require 'spec_helper'

describe AgnosticBackend::Queryable::Value do

  let(:value) { 1 }
  let(:parent) { double('Parent') }
  let(:context) { double('Context') }
  subject { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

  describe '#initialize' do
    it 'should assign the value' do
      expect(subject.value).to eq value
    end

    it 'it should assign the parent' do
      expect(subject.parent).to eq parent
    end
  end

  describe '#==' do
    context 'given two value objects' do
      it 'should be equal if value values are equal' do
        other_value =  AgnosticBackend::Queryable::Value.new(1, parent: parent, context: context)
        expect(subject).to eq other_value
      end

      it 'should not be equal if value values are not equal' do
        other_value =  AgnosticBackend::Queryable::Value.new('bar', parent: parent, context: context)
        expect(subject).not_to eq other_value
      end
    end
  end

  describe '#type' do
    context 'when associated attribute is absent' do
      it 'should return nil' do
        expect(parent).not_to respond_to :attribute
        expect(subject.type).to be_nil
      end
    end

    context 'when associated attribute is present' do
      it 'should return attribute type if associated attribute is defined in schema' do
        index = double('Index', schema: {'foo' => double('FieldType', type: :integer)})
        context = double('context', index: index)

        attribute = double('Attribute', name: 'foo')

        expect(parent).to receive(:attribute).and_return attribute
        expect(parent).to receive(:context).and_return context
        expect(subject.type).to eq :integer
      end

      it 'should return attribute type if associated attribute is defined in schema as association' do
        index = double('Index', schema: {'foo' => {'bar' => {'baz' => double('FieldType', type: :integer)}}})
        context = double('context', index: index)

        attribute = double('Attribute', name: 'foo.bar.baz')

        expect(parent).to receive(:attribute).and_return attribute
        expect(parent).to receive(:context).and_return context
        expect(subject.type).to eq :integer
      end
    end
  end
end