require 'spec_helper'

describe AgnosticStore::Queryable::Operations::Operation do
  context 'inheritance' do
    it { should be_a_kind_of(AgnosticStore::Queryable::TreeNode) }
  end

  context 'aliases' do
    let(:operands) { [:foo, :bar] }
    let(:context) { :context }
    let(:operation) { AgnosticStore::Queryable::Operations::Operation.new(operands, context) }

    describe '#operators' do
      it 'should be alias of children' do
        expect(operation.operands).to eq(operation.children)
      end
    end
  end
end