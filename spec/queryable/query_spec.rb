require 'spec_helper'

describe AgnosticBackend::Queryable::Query do

  let(:context) { double('Context') }

  context 'inheritance' do
    it { should be_a_kind_of(AgnosticBackend::Queryable::TreeNode) }
  end

  subject { AgnosticBackend::Queryable::Query.new(context) }

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

  describe '#execute' do
    it 'should be abstract' do
      expect { subject.execute }.to raise_error NotImplementedError
    end
  end

  describe '#valid?' do
    it 'receive accept with a new Validator' do
      expect(subject).to receive(:accept).with(instance_of(AgnosticBackend::Queryable::Validator))
      subject.valid?
    end
  end
end