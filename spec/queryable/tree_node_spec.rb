require 'spec_helper'

describe AgnosticBackend::Queryable::TreeNode do
  describe '#initialize' do
    context 'when no arguments given' do
      let(:tree_node) { AgnosticBackend::Queryable::TreeNode.new }

      it 'should have the default children' do
        expect(tree_node.children).to be_empty
      end
      it 'should have the default root' do
        expect(tree_node.context).to be_nil
      end
    end

    context 'when one argument is given' do
      let(:child) { double('Child') }
      let(:tree_node) { AgnosticBackend::Queryable::TreeNode.new([child]) }

      it 'should have the children provided' do
        expect(tree_node.children).to eq([child])
      end
      it 'should have the default context' do
        expect(tree_node.context).to be_nil
      end
    end

    context 'when two arguments are given' do
      let(:children) { [double('LeftChild'), double('RightChild')] }
      let(:context) { double('Context') }
      let(:tree_node) { AgnosticBackend::Queryable::TreeNode.new(children, context) }

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
        AgnosticBackend::Queryable::TreeNode.new()
      end

      let(:tree_node_2) do
        AgnosticBackend::Queryable::TreeNode.new([child_2])
      end

      it 'should return false' do
        expect(tree_node_1.children.size).not_to eq tree_node_2.children.size
        expect(tree_node_1).not_to eq tree_node_2
      end
    end

    context 'given two tree_node\'s with different classes' do
      let(:tree_node_1) do
        class TreeNodeOne < AgnosticBackend::Queryable::TreeNode; end
        TreeNodeOne.new
      end

      let(:tree_node_2) do
        class TreeNodeTwo < AgnosticBackend::Queryable::TreeNode; end
        TreeNodeTwo.new
      end

      it 'should return false' do
        expect(tree_node_1.class).not_to eq tree_node_2.class
        expect(tree_node_1).not_to eq tree_node_2
      end
    end

    context 'given two tree_node\'s with at least one child unequal' do
      let(:child_1) { double('Child') }
      let(:child_2) { double('Child') }

      let(:tree_node_1) do
        AgnosticBackend::Queryable::TreeNode.new([child_1])
      end

      let(:tree_node_2) do
        AgnosticBackend::Queryable::TreeNode.new([child_2])
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
        AgnosticBackend::Queryable::TreeNode.new([child_1])
      end

      let(:tree_node_2) do
        AgnosticBackend::Queryable::TreeNode.new([child_2])
      end

      it 'should return true' do
        expect(child_1).to receive(:==).with(child_2).and_return true
        expect(tree_node_1).to eq tree_node_2
      end
    end
  end

  let(:tree_node) { AgnosticBackend::Queryable::TreeNode.new }
  let(:context) { double('Context') }

  describe '#attribute_component' do
    it 'should return an Attribute instance' do
      attribute = tree_node.send(:attribute_component, attribute: attribute, context: context)
      expect(attribute).to be_an_instance_of AgnosticBackend::Queryable::Attribute
      expect(attribute.context).to eq context
    end
  end

  describe '#value_component' do
    it 'should return a Value instance' do
      value = tree_node.send(:value_component, value: value, context: context, type: :string)
      expect(value).to be_an_instance_of AgnosticBackend::Queryable::Value
      expect(value.context).to eq context
    end
  end
end
