require 'spec_helper'

describe AgnosticBackend::Queryable::Validator do

  let(:index) { double('Index', schema: {'attribute' => double('FieldType', type: :integer)}) }
  let(:query) { double('Query', errors: Hash.new{|hash, key| hash[key] = Array.new })}
  let(:context) { double('context', index: index, query: query) }

  describe '#visit_attribute' do
    let(:parent) do
      class DummyClass; end
      DummyClass.new
    end
    let(:attribute_name) { 'nested_model.attribute' }
    let(:visitor_subject) { AgnosticBackend::Queryable::Attribute.new(attribute_name, parent: parent, context: context) }

    context 'when schema does not have attribute name as key' do
      before do
        allow(subject).to receive(:value_for_key).with(index.schema, attribute_name).and_return nil
      end

      it 'should append error to query errors' do
        expect(subject).to receive(:visit_attribute).and_call_original
        subject.visit(visitor_subject)
        expect(query.errors).to eq({'AgnosticBackend::Queryable::Attribute'=>['Attribute \'nested_model.attribute\' in DummyClass missing from schema']})
      end

      it 'should change validator state to invalid' do
        expect(subject).to receive(:visit_attribute).and_call_original
        subject.visit(visitor_subject)
        expect(subject.instance_variable_get('@valid')).to be_false
      end
    end

    context 'when schema does have attribute name as key' do
      before do
        allow(subject).to receive(:value_for_key).with(index.schema, attribute_name).and_return 'the_attribute'
      end

      it 'should leave query errors empty' do
        expect(subject).to receive(:visit_attribute).and_call_original
        subject.visit(visitor_subject)
        expect(query.errors).to be_empty
      end

      it 'should keep validator state to valid' do
        expect(subject).to receive(:visit_attribute).and_call_original
        subject.visit(visitor_subject)
        expect(subject.instance_variable_get('@valid')).to be_true
      end
    end
  end
end
