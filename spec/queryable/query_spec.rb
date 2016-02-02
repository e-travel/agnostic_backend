require 'spec_helper'

describe AgnosticStore::Queryable::Query do

  let(:context) { double('context') }

  context 'inheritance' do
    it { should be_a_kind_of(AgnosticStore::Queryable::TreeNode) }
  end

  subject { AgnosticStore::Queryable::Query.new(context) }

  describe '#initialize' do
    it 'should have the default children' do
      expect(subject.children).to be_empty
    end

    it 'should have context as context' do
      expect(subject.context).to eq context
    end

    it 'should have errors attribute' do
      expect(subject.errors).to be_empty
    end
  end
end