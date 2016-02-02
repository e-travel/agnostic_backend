require 'spec_helper'

describe AgnosticBackend::Queryable::Criteria::Binary do

  let(:properties) { ['foo', 'bar'] }
  let(:parent) { double('Parent') }
  let(:context) { double('Context') }
  let(:criterion) { AgnosticBackend::Queryable::Criteria::Binary.new(properties, context) }

  context 'inheritance' do
    it 'should inherit form criterion' do
      expect(criterion).to be_a_kind_of(AgnosticBackend::Queryable::Criteria::Criterion)
    end
  end

  describe '#attribute' do
    it 'should be first child' do
      expect(criterion.attribute).to eq('foo')
    end
  end

  describe '#value' do
    it 'should be second child' do
      expect(criterion.value).to eq('bar')
    end
  end

  context 'Relational Criteria' do
    context 'Relational Criterion' do
      let(:relational_criterion) { AgnosticBackend::Queryable::Criteria::Relational.new(properties, context) }
      it 'should inherit from Binary criterion' do
        expect(relational_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Binary
      end

      describe '#properties_to_attr_value' do
        it 'should return a pair of Attribute and Value objects' do
          attribute = relational_criterion.send(:properties_to_attr_value, properties, context)[0]
          value = relational_criterion.send(:properties_to_attr_value, properties, context)[1]

          expect(attribute).to be_an_instance_of AgnosticBackend::Queryable::Attribute
          expect(attribute.context).to eq context
          expect(value).to be_an_instance_of AgnosticBackend::Queryable::Value
          expect(value.context).to eq context
        end
      end
    end

    context 'Equal Criterion' do
      let(:equal_criterion) { AgnosticBackend::Queryable::Criteria::Equal.new(properties, context) }
      it 'should inherit from Relational criterion' do
        expect(equal_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Relational
      end
    end

    context 'NotEqual Criterion' do
      let(:not_equal_criterion) { AgnosticBackend::Queryable::Criteria::NotEqual.new(properties, context) }
      it 'should inherit from Relational criterion' do
        expect(not_equal_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Relational
      end
    end

    context 'Greater Criterion' do
      let(:greater_criterion) { AgnosticBackend::Queryable::Criteria::Greater.new(properties, context) }
      it 'should inherit from Relational criterion' do
        expect(greater_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Relational
      end
    end

    context 'Less Criterion' do
      let(:less_criterion) { AgnosticBackend::Queryable::Criteria::Less.new(properties, context) }
      it 'should inherit from Relational criterion' do
        expect(less_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Relational
      end
    end

    context 'Contain Criterion' do
      let(:contain_criterion) { AgnosticBackend::Queryable::Criteria::Contain.new(properties, context) }
      it 'should inherit from Relational criterion' do
        expect(contain_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Relational
      end
    end

    context 'Start Criterion' do
      let(:start_criterion) { AgnosticBackend::Queryable::Criteria::Start.new(properties, context) }
      it 'should inherit from Relational criterion' do
        expect(start_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Relational
      end
    end
  end
end