require 'spec_helper'

describe AgnosticBackend::Queryable::Criteria::Ternary do

  let(:properties) { ['foo', 5, 10] }
  let(:parent) { double('Parent') }
  let(:context) { double('context') }
  let(:criterion) { AgnosticBackend::Queryable::Criteria::Ternary.new(properties, context) }

  context 'inheritance' do
    it 'should inherit from Criterion' do
      expect(criterion).to be_a_kind_of(AgnosticBackend::Queryable::Criteria::Criterion)
    end
  end

  describe '#attribute' do
    it 'should be first child' do
      expect(criterion.attribute).to eq('foo')
    end
  end

  describe '#left_value' do
    it 'should be second child' do
      expect(criterion.left_value).to eq(5)
    end
  end

  describe '#right_value' do
    it 'should be third child' do
      expect(criterion.right_value).to eq(10)
    end
  end

  context 'Between Criteria' do
    let(:between_criterion) { AgnosticBackend::Queryable::Criteria::Between.new(properties, context) }
    describe '#properties_to_attr_value' do
      it 'should return a triple of Attribute and Values objects' do
        attribute = between_criterion.send(:properties_to_attr_value, properties, context)[0]
        left_value = between_criterion.send(:properties_to_attr_value, properties, context)[1]
        right_value = between_criterion.send(:properties_to_attr_value, properties, context)[2]

        expect(attribute).to be_an_instance_of AgnosticBackend::Queryable::Attribute
        expect(attribute.context).to eq context
        expect(left_value).to be_an_instance_of AgnosticBackend::Queryable::Value
        expect(left_value.context).to eq context
        expect(right_value).to be_an_instance_of AgnosticBackend::Queryable::Value
        expect(right_value.context).to eq context
      end
    end

    context 'GreaterAndLess criterion' do
      let(:greater_and_less_criterion) { AgnosticBackend::Queryable::Criteria::GreaterAndLess.new(properties, context) }
      it 'should inherit from Between criterion' do
        expect(greater_and_less_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Between
      end
    end

    context 'GreaterEqualAndLess criterion' do
      let(:greater_equal_and_lees_criterion) { AgnosticBackend::Queryable::Criteria::GreaterEqualAndLess.new(properties, context) }
      it 'should inherit from Relational criterion' do
        expect(greater_equal_and_lees_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Between
      end
    end

    context 'GreaterAndLessEqual criterion' do
      let(:greater_and_less_equal_criterion) { AgnosticBackend::Queryable::Criteria::GreaterAndLessEqual.new(properties, context) }
      it 'should inherit from Relational criterion' do
        expect(greater_and_less_equal_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Between
      end
    end

    context 'GreaterEqualAndLessEqual criterion' do
      let(:greater_equal_and_less_equal_criterion) { AgnosticBackend::Queryable::Criteria::GreaterEqualAndLessEqual.new(properties, context) }
      it 'should inherit from Relational criterion' do
        expect(greater_equal_and_less_equal_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Between
      end
    end
  end
end
