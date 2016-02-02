require 'spec_helper'

describe AgnosticStore::Queryable::TreeNode do
  describe '#initialize' do
    context 'when no arguments given' do
      let(:tree_node) { AgnosticStore::Queryable::TreeNode.new }

      it 'should have the default children' do
        expect(tree_node.children).to be_empty
      end
      it 'should have the default root' do
        expect(tree_node.context).to be_nil
      end
    end

    context 'when one argument is given' do
      let(:child) { double('Child') }
      let(:tree_node) { AgnosticStore::Queryable::TreeNode.new([child]) }

      it 'should have the children provided' do
        expect(tree_node.children).to eq([child])
      end
      it 'should have the default context' do
        expect(tree_node.context).to be_nil
      end
    end

    context 'when two arguments are given' do
      let(:children) { [:foo, :bar] }
      let(:context) { :context }
      let(:tree_node) { AgnosticStore::Queryable::TreeNode.new(children, context) }

      it 'should have the children provided' do
        expect(tree_node.children).to eq(children)
      end
      it 'should have the context provided' do
        expect(tree_node.context).to eq(context)
      end
    end
  end

  describe '#accept' do
    let(:visitor) { double('Visitor')}
    it 'should call visit on object provided' do
      expect(visitor).to receive(:visit).with(subject)
      subject.accept(visitor)
    end
  end

  describe '#==' do
    context 'given two tree_node\'s with different children size' do
      let(:child_2) { double('Child') }

      let(:tree_node_1) do
        AgnosticStore::Queryable::TreeNode.new()
      end

      let(:tree_node_2) do
        AgnosticStore::Queryable::TreeNode.new([child_2])
      end

      it 'should return false' do
        expect(tree_node_1.children.size).not_to eq tree_node_2.children.size
        expect(tree_node_1).not_to eq tree_node_2
      end
    end

    context 'given two tree_node\'s with different classes' do
      let(:tree_node_1) do
        class TreeNodeOne < AgnosticStore::Queryable::TreeNode; end
        TreeNodeOne.new
      end

      let(:tree_node_2) do
        class TreeNodeTwo < AgnosticStore::Queryable::TreeNode; end
        TreeNodeTwo.new
      end

      it 'should return false' do
        expect(tree_node_1.class).not_to eq tree_node_2.class
        expect(tree_node_1).not_to eq tree_node_2
      end
    end

    context 'given two tree_node\'s with at letree_node one  child unequal' do
      let(:child_1) { double('Child') }
      let(:child_2) { double('Child') }

      let(:tree_node_1) do
        AgnosticStore::Queryable::TreeNode.new([child_1])
      end

      let(:tree_node_2) do
        AgnosticStore::Queryable::TreeNode.new([child_2])
      end

      it 'should return false' do
        expect(child_1).to receive(:==).with(child_2).and_return false
        expect(tree_node_1).not_to eq tree_node_2
      end
    end

    context 'given two tree_node\'s with all children equal' do
      let(:child_1) { double('Child') }
      let(:child_2) { double('Child') }


      let(:tree_node_1) do
        AgnosticStore::Queryable::TreeNode.new([child_1])
      end

      let(:tree_node_2) do
        AgnosticStore::Queryable::TreeNode.new([child_2])
      end

      it 'should return true' do
        expect(child_1).to receive(:==).with(child_2).and_return true
        expect(tree_node_1).to eq tree_node_2
      end
    end
  end
end
