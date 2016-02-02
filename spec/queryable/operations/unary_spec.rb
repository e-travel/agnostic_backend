require 'spec_helper'

describe AgnosticStore::Queryable::Operations::Unary do

  let(:operands) { [:foo] }
  let(:context) { :context }
  let(:operation) { AgnosticStore::Queryable::Operations::Unary.new(operands, context) }

  context 'inheritance' do
    it 'should inherit from operation' do
      expect(operation).to be_a_kind_of(AgnosticStore::Queryable::Operations::Operation)
    end
  end

  describe '#operand' do
    it 'should be first child' do
      expect(operation.operand).to eq(:foo)
    end
  end

  context 'Not operation' do
    let(:not_operation) { AgnosticStore::Queryable::Operations::Not.new(operands, context) }
    it 'should inherit from Unary operation' do
      expect(not_operation).to be_a_kind_of AgnosticStore::Queryable::Operations::Unary
    end
  end

  context 'Ascending operation' do
    let(:asc_operation) { AgnosticStore::Queryable::Operations::Ascending.new(operands, context) }
    it 'should inherit from Unary operation' do
      expect(asc_operation).to be_a_kind_of AgnosticStore::Queryable::Operations::Unary
    end

    context 'aliases' do
      describe '#attribute' do
        it 'should be alias of operand' do
          expect(asc_operation.attribute).to eq(asc_operation.operand)
        end
      end
    end

    it 'should map operand to value' do
      expect(asc_operation.operand).to be_a_kind_of AgnosticStore::Queryable::Attribute
    end
  end

  context 'Descending operation' do
    let(:desc_operation) { AgnosticStore::Queryable::Operations::Descending.new(operands, context) }
    it 'should inherit from Unary operation' do
      expect(desc_operation).to be_a_kind_of(AgnosticStore::Queryable::Operations::Unary)
    end

    context 'aliases' do
      describe '#attribute' do
        it 'should be alias of operand' do
          expect(desc_operation.attribute).to eq(desc_operation.operand)
        end
      end
    end

    it 'should map operator to value' do
      expect(desc_operation.operand).to be_a_kind_of AgnosticStore::Queryable::Attribute
    end
  end
end