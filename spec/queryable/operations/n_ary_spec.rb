require 'spec_helper'

describe AgnosticStore::Queryable::Operations::NAry do

  let(:operators) { [:foo, :bar, :baz] }
  let(:context) { :context }
  let(:operation) { AgnosticStore::Queryable::Operations::NAry.new(operators, context) }

  context 'inheritance' do
    it 'should inherit from Operation' do
      expect(operation).to be_a_kind_of(AgnosticStore::Queryable::Operations::Operation)
    end
  end

  context 'And operation' do
    let(:and_operation) { AgnosticStore::Queryable::Operations::And.new(operators, context) }
    it 'should inherit from N-Ary operation' do
      expect(and_operation).to be_a_kind_of AgnosticStore::Queryable::Operations::NAry
    end
  end

  context 'Or operation' do
    let(:or_operation) { AgnosticStore::Queryable::Operations::Or.new(operators, context) }
    it 'should inherit from N-Ary operation' do
      expect(or_operation).to be_a_kind_of AgnosticStore::Queryable::Operations::NAry
    end
  end
end