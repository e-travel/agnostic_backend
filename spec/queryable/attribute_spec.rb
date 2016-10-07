require 'spec_helper'

describe AgnosticBackend::Queryable::Attribute do

  describe '#initialize' do

    let(:name) { 'foo' }
    let(:parent) { double('Parent') }
    let(:context) { double('Context') }

    subject { AgnosticBackend::Queryable::Attribute.new(name, parent: parent, context: context) }

    context 'inheritance' do
      it 'should inherit form TreeNode' do
        expect(subject).to be_a_kind_of(AgnosticBackend::Queryable::TreeNode)
      end
    end

    describe '#initialize' do
      it 'should have no children' do
        expect(subject.children).to be_empty
      end
    end

    describe '#any?' do
      context 'given an attribute with `*` name' do
        subject { AgnosticBackend::Queryable::Attribute.new('*', parent: parent, context: context) }

          it 'should return true' do
          expect(subject).to be_any
        end
      end

      context 'given an attribute with not `*` name' do
        it 'should return false' do
          expect(subject).not_to be_any
        end
      end
    end

    describe '#score?' do
      context 'given an attribute with `_score` name' do
        subject { AgnosticBackend::Queryable::Attribute.new('_score', parent: parent, context: context) }

        it 'should return true' do
          expect(subject.score?).to be true
        end
      end

      context 'given an attribute with not `_score` name' do
        it 'should return false' do
          expect(subject.score?).to be false
        end
      end
    end

    describe '#==' do
      context 'given two attribute objects' do
        it 'should be equal if attribute names are equal' do
          other_attribute = AgnosticBackend::Queryable::Attribute.new('foo', parent: parent, context: context)
          expect(subject).to eq other_attribute
        end

        it 'should not be equal if attribute names are not equal' do
          other_attribute = AgnosticBackend::Queryable::Attribute.new('bar', parent: parent, context: context)
          expect(subject).not_to eq other_attribute
        end
      end
    end
  end
end