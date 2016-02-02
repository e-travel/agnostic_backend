require 'spec_helper'

describe AgnosticBackend::Queryable::Criteria::Criterion do
  context 'inheritance' do
    it { should be_a_kind_of(AgnosticBackend::Queryable::TreeNode) }
  end

  context 'aliases' do
    let(:components) { ['foo', 'bar'] }
    let(:context) { double('Context') }
    let(:criterion) { AgnosticBackend::Queryable::Criteria::Criterion.new(components, context) }

    describe '#components' do
      it 'should be alias of children' do
        expect(criterion.components).to eq(criterion.children)
      end
    end
  end
end