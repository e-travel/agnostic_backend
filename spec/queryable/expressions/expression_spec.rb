require 'spec_helper'

describe AgnosticBackend::Queryable::Expressions::Expression do
  context 'inheritance' do
    it { should be_a_kind_of(AgnosticBackend::Queryable::TreeNode) }
  end

  let(:operator) { [:foo] }
  let(:base) { :base }
  let(:expression) { AgnosticBackend::Queryable::Expressions::Expression.new(operator, base) }


  context 'Where Expression' do
    let(:restrictions) { [:foo, :bar, :baz]}
    let(:where_expression) { AgnosticBackend::Queryable::Expressions::Where.new([restrictions], base) }

    it 'should inherit from Expression' do
      expect(where_expression).to be_a_kind_of AgnosticBackend::Queryable::Expressions::Expression
    end

    context 'aliases' do
      describe '#restrictions' do
        it 'should be alias of children' do
          expect(where_expression.restrictions).to eq(where_expression.children)
        end
      end
    end
  end

  context 'Select Expression' do
    let(:projections) { [:foo, :bar, :baz]}
    let(:select_expression) { AgnosticBackend::Queryable::Expressions::Select.new([projections], base) }

    it 'should inherit from Expression' do
      expect(select_expression).to be_a_kind_of AgnosticBackend::Queryable::Expressions::Expression
    end

    context 'aliases' do
      describe '#projections' do
        it 'should be alias of children' do
          expect(select_expression.projections).to eq(select_expression.children)
        end
      end
    end

    it 'should map projections to attributes' do
      expect(select_expression.projections.all?{|p| p.is_a? AgnosticBackend::Queryable::Attribute}).to be_true
    end
  end

  context 'Order Expression' do
    let(:qualifiers) { [double('AscendingOrder'), double('DescendingOrder')] }
    let(:order_expression) { AgnosticBackend::Queryable::Expressions::Order.new([qualifiers], base) }

    it 'should inherit from Expression' do
      expect(order_expression).to be_a_kind_of AgnosticBackend::Queryable::Expressions::Expression
    end

    context 'aliases' do
      describe '#qualifiers' do
        it 'should be alias of children' do
          expect(order_expression.qualifiers).to eq(order_expression.children)
        end
      end
    end
  end

  context 'Limit Expression' do
    let(:limit) { 1 }
    let(:limit_expression) { AgnosticBackend::Queryable::Expressions::Limit.new(limit, base) }

    it 'should inherit from Expression' do
      expect(limit_expression).to be_a_kind_of AgnosticBackend::Queryable::Expressions::Expression
    end

    it 'should map limit to value' do
      expect(limit_expression.limit).to be_a AgnosticBackend::Queryable::Value
    end

    describe '#limit' do
      it 'should be first child' do
        expect(limit_expression.limit).to eq(limit_expression.children.first)
      end
    end
  end

  context 'Offset Expression' do
    let(:offset) { 1 }
    let(:offset_expression) { AgnosticBackend::Queryable::Expressions::Offset.new(offset, base) }

    it 'should inherit from Expression' do
      expect(offset_expression).to be_a_kind_of AgnosticBackend::Queryable::Expressions::Expression
    end

    it 'should map offset to value' do
      expect(offset_expression.offset).to be_a AgnosticBackend::Queryable::Value
    end

    describe '#offset' do
      it 'should be first child' do
        expect(offset_expression.offset).to eq(offset_expression.children.first)
      end
    end
  end
end