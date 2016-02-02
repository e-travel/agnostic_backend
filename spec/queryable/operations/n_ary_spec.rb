require 'spec_helper'

describe AgnosticBackend::Queryable::Operations::NAry do

  let(:operands) { ['foo', 'bar', 'baz'] }
  let(:context) { double('Context') }
  let(:operation) { AgnosticBackend::Queryable::Operations::NAry.new(operands: operands, context: context) }

  context 'inheritance' do
    it 'should inherit from Operation' do
      expect(operation).to be_a_kind_of(AgnosticBackend::Queryable::Operations::Operation)
    end
  end

  context 'And operation' do
    let(:and_operation) { AgnosticBackend::Queryable::Operations::And.new(operands: operands, context: context) }
    it 'should inherit from N-Ary operation' do
      expect(and_operation).to be_a_kind_of AgnosticBackend::Queryable::Operations::NAry
    end
  end

  context 'Or operation' do
    let(:or_operation) { AgnosticBackend::Queryable::Operations::Or.new(operands: operands, context: context) }
    it 'should inherit from N-Ary operation' do
      expect(or_operation).to be_a_kind_of AgnosticBackend::Queryable::Operations::NAry
    end
  end
end