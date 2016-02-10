require 'spec_helper'

describe AgnosticBackend::Queryable::Criteria::Binary do

  let(:schema) do
    {
        'an_integer' => double('FieldType', type: :integer),
        'a_string' => double('FieldType', type: :string),
        'a_date' => double('FieldType', type: :date)
    }
  end
  let(:index) { double('Index', schema: schema) }
  let(:context) { double('Context', index: index) }

  let(:attribute) { 'foo' }
  let(:value) { 'bar' }
  let(:criterion) { AgnosticBackend::Queryable::Criteria::Binary.new(attribute: attribute, value: value, context: context) }

  context 'inheritance' do
    it 'should inherit form criterion' do
      expect(criterion).to be_a_kind_of(AgnosticBackend::Queryable::Criteria::Criterion)
    end
  end

  describe '#attribute' do
    it 'should be the attribute component' do
      expect(criterion.attribute).to eq('foo')
    end
  end

  describe '#value' do
    it 'should be the value component' do
      expect(criterion.value).to eq('bar')
    end
  end

  context 'Relational Criteria' do
    context 'Relational Criterion' do
      let(:relational_criterion) { AgnosticBackend::Queryable::Criteria::Relational.new(attribute: attribute, value: value, context: context) }
      it 'should inherit from Binary criterion' do
        expect(relational_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Binary
      end

      it 'should map attribute to Value instance' do
        expect(relational_criterion.attribute).to be_a_kind_of AgnosticBackend::Queryable::Attribute
        expect(relational_criterion.attribute.parent).to eq relational_criterion
      end
      
      it 'should map value to Value instance' do
        expect(relational_criterion.value).to be_a_kind_of AgnosticBackend::Queryable::Value
        expect(relational_criterion.value.parent).to eq relational_criterion
      end
    end

    context 'Equal Criterion' do
      let(:equal_criterion) { AgnosticBackend::Queryable::Criteria::Equal.new(attribute: attribute, value: value, context: context) }
      it 'should inherit from Relational criterion' do
        expect(equal_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Relational
      end
    end

    context 'NotEqual Criterion' do
      let(:not_equal_criterion) { AgnosticBackend::Queryable::Criteria::NotEqual.new(attribute: attribute, value: value, context: context) }
      it 'should inherit from Relational criterion' do
        expect(not_equal_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Relational
      end
    end

    context 'Greater Criterion' do
      let(:greater_criterion) { AgnosticBackend::Queryable::Criteria::Greater.new(attribute: attribute, value: value, context: context) }
      it 'should inherit from Relational criterion' do
        expect(greater_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Relational
      end
    end

    context 'Less Criterion' do
      let(:less_criterion) { AgnosticBackend::Queryable::Criteria::Less.new(attribute: attribute, value: value, context: context) }
      it 'should inherit from Relational criterion' do
        expect(less_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Relational
      end
    end

    context 'Contains Criterion' do
      let(:contains_criterion) { AgnosticBackend::Queryable::Criteria::Contains.new(attribute: attribute, value: value, context: context) }
      it 'should inherit from Relational criterion' do
        expect(contains_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Relational
      end
    end

    context 'Start Criterion' do
      let(:starts_criterion) { AgnosticBackend::Queryable::Criteria::Starts.new(attribute: attribute, value: value, context: context) }
      it 'should inherit from Relational criterion' do
        expect(starts_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Relational
      end
    end
  end
end