require 'spec_helper'

describe AgnosticBackend::Queryable::Operations::NAry do

  let(:operators) { [:foo, :bar, :baz] }
  let(:context) { :context }
  let(:operation) { AgnosticBackend::Queryable::Operations::NAry.new(operators, context) }

  context 'inheritance' do
    it 'should inherit from Operation' do
      expect(operation).to be_a_kind_of(AgnosticBackend::Queryable::Operations::Operation)
    end
  end

  context 'And operation' do
    let(:and_operation) { AgnosticBackend::Queryable::Operations::And.new(operators, context) }
    it 'should inherit from N-Ary operation' do
      expect(and_operation).to be_a_kind_of AgnosticBackend::Queryable::Operations::NAry
    end
  end

  context 'Or operation' do
    let(:or_operation) { AgnosticBackend::Queryable::Operations::Or.new(operators, context) }
    it 'should inherit from N-Ary operation' do
      expect(or_operation).to be_a_kind_of AgnosticBackend::Queryable::Operations::NAry
    end
  end
end