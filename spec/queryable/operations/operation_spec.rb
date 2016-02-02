require 'spec_helper'

describe AgnosticBackend::Queryable::Operations::Operation do
  context 'inheritance' do
    it { should be_a_kind_of(AgnosticBackend::Queryable::TreeNode) }
  end

  context 'aliases' do
    let(:operands) { [:foo, :bar] }
    let(:context) { :context }
    let(:operation) { AgnosticBackend::Queryable::Operations::Operation.new(operands, context) }

    describe '#operators' do
      it 'should be alias of children' do
        expect(operation.operands).to eq(operation.children)
      end
    end
  end
end