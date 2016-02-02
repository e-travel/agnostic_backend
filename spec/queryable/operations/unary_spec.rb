require 'spec_helper'

describe AgnosticBackend::Queryable::Operations::Unary do

  let(:operand) { 'bar' }
  let(:attribute) { 'foo' }
  let(:context) { double('Context') }
  let(:operation) { AgnosticBackend::Queryable::Operations::Unary.new(operand: operand, context: context) }

  context 'inheritance' do
    it 'should inherit from operation' do
      expect(operation).to be_a_kind_of(AgnosticBackend::Queryable::Operations::Operation)
    end
  end

  context 'Not operation' do
    let(:not_operation) { AgnosticBackend::Queryable::Operations::Not.new(operand: operand, context: context) }
    it 'should inherit from Unary operation' do
      expect(not_operation).to be_a_kind_of AgnosticBackend::Queryable::Operations::Unary
    end
  end

  context 'OrderQualifier operation' do
    let(:order_qualifier_operation) { AgnosticBackend::Queryable::Operations::OrderQualifier.new(attribute: attribute, context: context) }
    it 'should inherit from Unary operation' do
      expect(order_qualifier_operation).to be_a_kind_of AgnosticBackend::Queryable::Operations::Unary
    end

    context 'aliases' do
      describe '#attribute' do
        it 'should be alias of operand' do
          expect(order_qualifier_operation.attribute).to eq(order_qualifier_operation.operand)
        end
      end
    end

    it 'should map operand to value' do
      expect(order_qualifier_operation.operand).to be_a_kind_of AgnosticBackend::Queryable::Attribute
      expect(order_qualifier_operation.operand.parent).to eq order_qualifier_operation
    end
  end

  context 'Ascending operation' do
    let(:asc_operation) { AgnosticBackend::Queryable::Operations::Ascending.new(attribute: attribute, context: context) }
    it 'should inherit from Unary operation' do
      expect(asc_operation).to be_a_kind_of AgnosticBackend::Queryable::Operations::Unary
    end
  end

  context 'Descending operation' do
    let(:desc_operation) { AgnosticBackend::Queryable::Operations::Descending.new(attribute: attribute, context: context) }
    it 'should inherit from Unary operation' do
      expect(desc_operation).to be_a_kind_of(AgnosticBackend::Queryable::Operations::Unary)
    end
  end
end