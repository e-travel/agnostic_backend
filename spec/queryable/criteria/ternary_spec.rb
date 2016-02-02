require 'spec_helper'

describe AgnosticBackend::Queryable::Criteria::Ternary do

  let(:attribute) { 'foo' }
  let(:left_value) { 5 }
  let(:right_value) { 10 }
  let(:context) { double('context') }
  let(:criterion) { AgnosticBackend::Queryable::Criteria::Ternary.new(attribute: attribute, left_value: left_value, right_value: right_value, context: context) }

  context 'inheritance' do
    it 'should inherit from Criterion' do
      expect(criterion).to be_a_kind_of(AgnosticBackend::Queryable::Criteria::Criterion)
    end
  end

  context 'Between Criteria' do
    context 'Between criterion' do
    let(:between_criterion) { AgnosticBackend::Queryable::Criteria::Between.new(attribute: attribute, left_value: left_value, right_value: right_value, context: context) }
      it 'should inherit from Ternary criterion' do
        expect(between_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Ternary
      end

      it 'should map attribute to Value instance' do
        expect(between_criterion.attribute).to be_a_kind_of AgnosticBackend::Queryable::Attribute
        expect(between_criterion.attribute.parent).to eq between_criterion
      end
      
      it 'should map left_value to Value instance' do
        expect(between_criterion.left_value).to be_a_kind_of AgnosticBackend::Queryable::Value
        expect(between_criterion.left_value.parent).to eq between_criterion
      end

      it 'should map right_value to Value instance' do
        expect(between_criterion.right_value).to be_a_kind_of AgnosticBackend::Queryable::Value
        expect(between_criterion.right_value.parent).to eq between_criterion
      end
    end

    context 'GreaterAndLess criterion' do
      let(:greater_and_less_criterion) { AgnosticBackend::Queryable::Criteria::GreaterAndLess.new(attribute: attribute, left_value: left_value, right_value: right_value, context: context) }
      it 'should inherit from Between criterion' do
        expect(greater_and_less_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Between
      end
    end

    context 'GreaterEqualAndLess criterion' do
      let(:greater_equal_and_lees_criterion) { AgnosticBackend::Queryable::Criteria::GreaterEqualAndLess.new(attribute: attribute, left_value: left_value, right_value: right_value, context: context) }
      it 'should inherit from Relational criterion' do
        expect(greater_equal_and_lees_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Between
      end
    end

    context 'GreaterAndLessEqual criterion' do
      let(:greater_and_less_equal_criterion) { AgnosticBackend::Queryable::Criteria::GreaterAndLessEqual.new(attribute: attribute, left_value: left_value, right_value: right_value, context: context) }
      it 'should inherit from Relational criterion' do
        expect(greater_and_less_equal_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Between
      end
    end

    context 'GreaterEqualAndLessEqual criterion' do
      let(:greater_equal_and_less_equal_criterion) { AgnosticBackend::Queryable::Criteria::GreaterEqualAndLessEqual.new(attribute: attribute, left_value: left_value, right_value: right_value, context: context) }
      it 'should inherit from Relational criterion' do
        expect(greater_equal_and_less_equal_criterion).to be_a_kind_of AgnosticBackend::Queryable::Criteria::Between
      end
    end
  end
end
