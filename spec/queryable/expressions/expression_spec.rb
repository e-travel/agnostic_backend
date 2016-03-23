require 'spec_helper'

describe AgnosticBackend::Queryable::Expressions::Expression do
  context 'inheritance' do
    it { should be_a_kind_of(AgnosticBackend::Queryable::TreeNode) }
  end

  let(:schema) do
    {
        'an_integer' => double('FieldType', type: :integer),
        'a_string' => double('FieldType', type: :string),
        'a_date' => double('FieldType', type: :date)
    }
  end
  let(:index) { double('Index', schema: schema) }
  let(:context) { double('Context', index: index) }
  let(:expression) { AgnosticBackend::Queryable::Expressions::Expression.new(operator, base) }

  context 'Where Expression' do
    let(:an_equal_criterion) { AgnosticBackend::Queryable::Criteria::Equal.new(attribute: 'an_integer', value: 10, context: context)}
    let(:a_not_equal_criterion) { AgnosticBackend::Queryable::Criteria::Equal.new(attribute: 'a_string', value: 'value', context: context)}
    let(:and_criterion) { AgnosticBackend::Queryable::Operations::And.new(operands: [an_equal_criterion, a_not_equal_criterion], context: context)}
    let(:where_expression) { AgnosticBackend::Queryable::Expressions::Where.new(criterion: and_criterion, context: context)}

    it 'should inherit from Expression' do
      expect(where_expression).to be_a_kind_of AgnosticBackend::Queryable::Expressions::Expression
    end

    context 'aliases' do
      describe '#criterion' do
        it 'should be the first children' do
          expect(where_expression.criterion).to eq(where_expression.children.first)
        end
      end
    end
  end

  context 'Select Expression' do
    let(:projections) { ['an_integer','a_string','a_date'] }
    let(:select_expression) { AgnosticBackend::Queryable::Expressions::Select.new(attributes: [projections], context: context) }

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
      expect(select_expression.projections.all?{|p| p.is_a? AgnosticBackend::Queryable::Attribute}).to be true
    end
  end

  context 'Order Expression' do
    let(:ascending_qualifier) { AgnosticBackend::Queryable::Operations::Ascending.new(attribute: 'a_string', context: context) }
    let(:descending_qualifier) { AgnosticBackend::Queryable::Operations::Descending.new(attribute: 'an_integer', context: context) }
    let(:order_expression) { AgnosticBackend::Queryable::Expressions::Order.new(attributes: [ascending_qualifier, descending_qualifier], context: context) }

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
    let(:limit_expression) { AgnosticBackend::Queryable::Expressions::Limit.new(value: limit, context: context) }

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
    let(:offset_expression) { AgnosticBackend::Queryable::Expressions::Offset.new(value: offset, context: context) }

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

  context 'Scroll Cursor Expression' do
    let(:scroll_cursor) { 'foo' }
    let(:scroll_cursor_expression) { AgnosticBackend::Queryable::Expressions::ScrollCursor.new(value: scroll_cursor, context: context) }

    it 'should inherit from Expression' do
      expect(scroll_cursor_expression).to be_a_kind_of AgnosticBackend::Queryable::Expressions::Expression
    end

    it 'should map scroll cursor to value' do
      expect(scroll_cursor_expression.scroll_cursor).to be_a AgnosticBackend::Queryable::Value
    end

    describe '#scroll_cursor' do
      it 'should be first child' do
        expect(scroll_cursor_expression.scroll_cursor).to eq(scroll_cursor_expression.children.first)
      end
    end
  end
end
