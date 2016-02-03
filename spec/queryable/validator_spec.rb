require 'spec_helper'

describe AgnosticBackend::Queryable::Validator do

  let(:index) { double('Index', schema: {'attribute' => double('FieldType', type: :integer)}) }
  let(:query) { double('Query', errors: Hash.new{|hash, key| hash[key] = Array.new })}
  let(:context) { double('context', index: index, query: query) }

  let(:parent) do
    class DummyClass; end
    DummyClass.new
  end

  describe '#visit_attribute' do
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

  describe '#visit_value' do
    let(:attribute_name) { 'nested_model.attribute' }
    let(:associated_attribute) { AgnosticBackend::Queryable::Attribute.new(attribute_name, parent: parent, context: context) }

    context 'when value does not have the required type' do
      context ':integer type' do
        let(:value) { '1' }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:integer)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as integer type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be_false
        end
      end

      context ':double type' do
        let(:value) { 5 }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:double)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as double type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be_false
        end
      end

      context ':string type' do
        let(:value) { 1 }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:string)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as string type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be_false
        end
      end

      context ':string_array type' do
        let(:value) { 1.23 }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:string_array)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as string_array type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be_false
        end
      end

      context ':text type' do
        let(:value) { true }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:text)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as text type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be_false
        end
      end

      context ':text_array type' do
        let(:value) { DateTime.now }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:text_array)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as text_array type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be_false
        end
      end

      context ':date type' do
        let(:value) { '01-01-2016' }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:date)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as date type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be_false
        end
      end

      context ':boolean type' do
        let(:value) { 'true' }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:boolean)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as boolean type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be_false
        end
      end
    end

    context 'when value has the required type' do
      let(:value) { 1 }
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

      before do
        allow(visitor_subject).to receive(:type).and_return(:integer)
        allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
      end

      it 'should append error to query errors' do
        expect(subject).to receive(:visit_value).and_call_original
        subject.visit(visitor_subject)
        expect(query.errors).to be_empty
      end

      it 'should change validator state to invalid' do
        expect(subject).to receive(:visit_value).and_call_original
        subject.visit(visitor_subject)
        expect(subject.instance_variable_get('@valid')).to be_true
      end
    end

    context 'when value has not type' do
      let(:value) { 1 }
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

      before do
        allow(visitor_subject).to receive(:type).and_return(nil)
        allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
      end

      it 'should append error to query errors' do
        expect(subject).to receive(:visit_value).and_call_original
        subject.visit(visitor_subject)
        expect(query.errors).to be_empty
      end

      it 'should change validator state to invalid' do
        expect(subject).to receive(:visit_value).and_call_original
        subject.visit(visitor_subject)
        expect(subject.instance_variable_get('@valid')).to be_true
      end
    end
  end
end
