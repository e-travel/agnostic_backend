require 'spec_helper'

describe AgnosticStore::Queryable::Attribute do

  describe '#initialize' do

    let(:name) { 'foo' }
    let(:parent) { double('Parent') }
    let(:context) { double('Context') }

    subject { AgnosticStore::Queryable::Attribute.new(name, parent: parent, context: context) }

    context 'inheritance' do
      it 'should inherit form TreeNode' do
        expect(subject).to be_a_kind_of(AgnosticStore::Queryable::TreeNode)
      end
    end

    describe '#initialize' do
      it 'should have no children' do
        expect(subject.children).to be_empty
      end
    end

    describe '#==' do
      context 'given two attribute objects' do
        it 'should be equal if attribute names are equal' do
          other_attribute = AgnosticStore::Queryable::Attribute.new('foo', parent: parent, context: context)
          expect(subject).to eq other_attribute
        end

        it 'should not be equal if attribute names are not equal' do
          other_attribute = AgnosticStore::Queryable::Attribute.new('bar', parent: parent, context: context)
          expect(subject).not_to eq other_attribute
        end
      end
    end
  end
end