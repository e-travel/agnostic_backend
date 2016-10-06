require 'spec_helper'

describe AgnosticBackend::Queryable::QueryBuilder do

  let(:index) { double('Index') }

  subject do
    AgnosticBackend::Queryable::QueryBuilder.new(index)
  end

  describe '#criteria_builder' do
    it 'should create a CriteriaBuilder' do
      expect(AgnosticBackend::Queryable::CriteriaBuilder).to receive(:new).with(subject).and_call_original
      expect(subject.criteria_builder).to be_a AgnosticBackend::Queryable::CriteriaBuilder
    end
  end

  describe '#where' do
    let(:criterion) { double('Criterion') }

    it 'should assign argument to criteria instance variable' do
      expect(subject.where(criterion)).to eq subject
      expect(subject.instance_variable_get(:@criterion)).to eq criterion
    end
  end

  describe '#filter' do
    let(:filter) { double('Filter') }

    it 'should assign argument to filter instance variable' do
      expect(subject.filter(filter)).to eq subject
      expect(subject.instance_variable_get(:@filter)).to eq filter
    end
  end

  describe '#select' do
    let(:projections) { ['a'] }

    context 'when projections instance variable is not present' do
      it 'should create projections instance variable and append arguments' do
        expect(subject.instance_variable_get(:@projections)).to be_nil
        expect(subject.select(*projections)).to eq subject
        expect(subject.instance_variable_get(:@projections)).to eq projections
      end
    end

    context 'when projections instance variable is present' do
      let(:new_projections) { ['b', 'c'] }

      it 'should append arguments to projections instance variable' do
        subject.instance_variable_set(:@projections, projections)
        expect(subject.select(*new_projections)).to eq subject
        expect(subject.instance_variable_get(:@projections)).to eq ['a', 'b', 'c']
      end
    end
  end

  describe '#order' do
    let(:ascending_attribute) { 'a' }
    let(:ascending_order_qualifier) { AgnosticBackend::Queryable::Operations::Ascending.new(attribute: ascending_attribute, context: subject) }

    context 'when projections instance variable is not present' do
      it 'should create projections instance variable and append arguments' do
        expect(subject.instance_variable_get(:@order_qualifiers)).to be_nil
        expect(subject.order(ascending_attribute, :asc)).to eq subject
        expect(subject.instance_variable_get(:@order_qualifiers)).to eq [ascending_order_qualifier]
      end
    end

    context 'when projections instance variable is present' do
      let(:descending_attribute) { 'a' }
      let(:descending_order_qualifier) { AgnosticBackend::Queryable::Operations::Descending.new(attribute: ascending_attribute, context: subject) }

      it 'should append arguments to projections instance variable' do
        subject.instance_variable_set(:@order_qualifiers, [ascending_order_qualifier])
        expect(subject.order(descending_attribute, :desc)).to eq subject
        expect(subject.instance_variable_get(:@order_qualifiers)).to eq [ascending_order_qualifier, descending_order_qualifier]
      end
    end
  end

  describe '#limit' do
    let(:limit) { double('Limit') }

    it 'should assign argument to limit instance variable' do
      expect(subject.limit(limit)).to eq subject
      expect(subject.instance_variable_get(:@limit)).to eq limit
    end
  end

  describe '#offset' do
    let(:offset) { double('Offset') }

    it 'should assign argument to offset instance variable' do
      expect(subject.offset(offset)).to eq subject
      expect(subject.instance_variable_get(:@offset)).to eq offset
    end
  end


  describe '#scroll_cursor' do
    let(:scroll_cursor) { double('ScrollCursor') }

    it 'should assign argument to scroll_cursor instance variable' do
      expect(subject.scroll_cursor(scroll_cursor)).to eq subject
      expect(subject.instance_variable_get(:@scroll_cursor)).to eq scroll_cursor
    end
  end

  describe '#build' do
    before do
      allow(subject).to receive(:create_query).and_return query
    end

    let(:query) { double('Query', children: [])}

    it 'should build query' do
      expect(subject).to receive(:create_query).with(subject, {}).and_return(query)
      expect(subject.build).to eq query
    end

    context 'when criteria instance variable is defined' do
      let(:criterion) { double('Criterion') }
      let(:where_expression) { double('WhereExpression') }

      it 'should build a where expression and append to query\'s children' do
        subject.instance_variable_set(:@criterion, criterion)
        expect(subject).to receive(:build_where_expression).and_return where_expression

        expect(subject.build).to eq query
        expect(query.children.first).to eq where_expression
      end
    end

    context 'when filter instance variable is defined' do
      let(:filter) { double('filter') }
      let(:filter_expression) { double('FilterExpression') }

      it 'should build a filter expression and append to query\'s children' do
        subject.instance_variable_set(:@filter, filter)
        expect(subject).to receive(:build_filter_expression).and_return filter_expression

        expect(subject.build).to eq query
        expect(query.children.first).to eq filter_expression
      end
    end

    context 'when projections instance variable is defined' do
      let(:projections) { double('projections') }
      let(:select_expression) { double('SelectExpression') }

      it 'should build a select expression and append to query\'s children' do
        subject.instance_variable_set(:@projections, projections)
        expect(subject).to receive(:build_select_expression).and_return select_expression

        expect(subject.build).to eq query
        expect(query.children.first).to eq select_expression
      end
    end

    context 'when order_qualifiers instance variable is defined' do
      let(:order_qualifiers) { double('order_qualifiers') }
      let(:order_expression) { double('OrderExpression') }

      it 'should build an order expression and append to query\'s children' do
        subject.instance_variable_set(:@order_qualifiers, order_qualifiers)
        expect(subject).to receive(:build_order_expression).and_return order_expression

        expect(subject.build).to eq query
        expect(query.children.first).to eq order_expression
      end
    end

    context 'when limit instance variable is defined' do
      let(:limit) { double('limit') }
      let(:limit_expression) { double('LimitExpression') }

      it 'should build an limit expression and append to query\'s children' do
        subject.instance_variable_set(:@limit, limit)
        expect(subject).to receive(:build_limit_expression).and_return limit_expression

        expect(subject.build).to eq query
        expect(query.children.first).to eq limit_expression
      end
    end

    context 'when offset instance variable is defined' do
      let(:offset) { double('offset') }
      let(:offset_expression) { double('OffsetExpression') }

      it 'should build an limit expression and append to query\'s children' do
        subject.instance_variable_set(:@offset, offset)
        expect(subject).to receive(:build_offset_expression).and_return offset_expression

        expect(subject.build).to eq query
        expect(query.children.first).to eq offset_expression
      end
    end

    context 'when build_cursor instance variable is defined' do
      let(:scroll_cursor) { double('ScrollCursor') }
      let(:scroll_cursor_expression) { double('ScrollCursorExpression') }

      it 'should build an scroll cursor expression and append to query\'s children' do
        subject.instance_variable_set(:@scroll_cursor, scroll_cursor)
        expect(subject).to receive(:build_scroll_cursor_expression).and_return scroll_cursor_expression

        expect(subject.build).to eq query
        expect(query.children.first).to eq scroll_cursor_expression
      end
    end
  end

  describe '#create_query' do
    it { expect{ subject.send(:create_query, 'base') }.to raise_error(NotImplementedError) }
  end

  describe '#build_where_expression' do
    let(:criterion) { double('Criterion') }

    it 'should create a Where Expression with criteria' do
      subject.instance_variable_set(:@criterion, criterion)
      expect(AgnosticBackend::Queryable::Expressions::Where).to receive(:new).with(criterion: criterion, context: subject)
      subject.send(:build_where_expression)
    end
  end

  describe '#build_select_expression' do
    let(:projections) { double('Projections') }

    it 'should create a Select Expression with projections' do
      subject.instance_variable_set(:@projections, projections)
      expect(AgnosticBackend::Queryable::Expressions::Select).to receive(:new).with(attributes: projections, context: subject)
      subject.send(:build_select_expression)
    end
  end

  describe '#build_order_expression' do
    let(:order_qualifiers) { double('order_qualifiers') }

    it 'should create an Order Expression with order_qualifiers' do
      subject.instance_variable_set(:@order_qualifiers, order_qualifiers)
      expect(AgnosticBackend::Queryable::Expressions::Order).to receive(:new).with(attributes: order_qualifiers, context: subject)
      subject.send(:build_order_expression)
    end
  end

  describe '#build_limit_expression' do
    let(:limit) { double('limit') }

    it 'should create a Limit Expression with limit' do
      subject.instance_variable_set(:@limit, limit)
      expect(AgnosticBackend::Queryable::Expressions::Limit).to receive(:new).with(value: limit, context: subject)
      subject.send(:build_limit_expression)
    end
  end

  describe '#build_offset_expression' do
    let(:offset) { double('offset') }

    it 'should create an Offset Expression with offset' do
      subject.instance_variable_set(:@offset, offset)
      expect(AgnosticBackend::Queryable::Expressions::Offset).to receive(:new).with(value: offset, context: subject)
      subject.send(:build_offset_expression)
    end
  end

  describe '#build_scroll_cursor_expression' do
    let(:scroll_cursor) { double('ScrollCursor') }

    it 'should create an Scroll Cursor Expression with scroll_cursor' do
      subject.instance_variable_set(:@scroll_cursor, scroll_cursor)
      expect(AgnosticBackend::Queryable::Expressions::ScrollCursor).to receive(:new).with(value: scroll_cursor, context: subject)
      subject.send(:build_scroll_cursor_expression)
    end
  end

  describe '#build_order_qualifier' do
    let(:attribute) { double('Attribute')}
    context 'when direction is :asc' do
      let(:ascending_operation) { double('AscendingOperation')}
      it 'should create and Ascending Operation' do
        expect(AgnosticBackend::Queryable::Operations::Ascending).to receive(:new).with(attribute: attribute, context: subject).and_return ascending_operation
        expect(subject.send(:build_order_qualifier, attribute, :asc)).to eq ascending_operation
      end
    end

    context 'when direction is :desc' do
      let(:descending_operation) { double('AscendingOperation')}

      it 'should create and Descending Operation' do
        expect(AgnosticBackend::Queryable::Operations::Descending).to receive(:new).with(attribute: attribute, context: subject).and_return descending_operation
        expect(subject.send(:build_order_qualifier, attribute, :desc)).to eq descending_operation
      end
    end
  end
end