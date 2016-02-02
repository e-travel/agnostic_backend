require 'spec_helper'

describe AgnosticStore::Queryable::QueryBuilder do

  let(:index) { double('Index') }

  subject do
    AgnosticStore::Queryable::QueryBuilder.new(index)
  end

  describe '#criteria_builder' do
    it 'should create a CriteriaBuilder' do
      expect(AgnosticStore::Queryable::CriteriaBuilder).to receive(:new).with(subject).and_call_original
      expect(subject.criteria_builder).to be_a AgnosticStore::Queryable::CriteriaBuilder
    end
  end

  describe '#where' do
    let(:criteria) { double('Criteria') }

    it 'should assign argument to criteria instance variable' do
      expect(subject.where(criteria)).to eq subject
      expect(subject.instance_variable_get(:@criteria)).to eq criteria
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

  describe '#build' do
    before do
      allow(subject).to receive(:create_query).and_return query
    end

    let(:query) { double('Query', children: [])}

    it 'should build query' do
      expect(subject).to receive(:create_query).with(subject).and_return(query)
      expect(subject.build).to eq query
    end

    context 'when criteria instance variable is defined' do
      let(:criteria) { double('Criteria') }
      let(:where_expression) { double('WhereExpression') }

      it 'should build a where expression and append to query\'s children' do
        subject.instance_variable_set(:@criteria, criteria)
        expect(subject).to receive(:build_where_expression).and_return where_expression

        expect(subject.build).to eq query
        expect(query.children.first).to eq where_expression
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
  end

  describe '#create_query' do
    it { expect{ subject.send(:create_query, 'base') }.to raise_error(NotImplementedError) }
  end

  describe '#build_where_expression' do
    let(:criteria) { double('Criteria') }

    it 'should create a Where Expression with criteria' do
      subject.instance_variable_set(:@criteria, criteria)
      expect(AgnosticStore::Queryable::Expressions::Where).to receive(:new).with(criteria ,subject)
      subject.send(:build_where_expression)
    end
  end

  describe '#build_select_expression' do
    let(:projections) { double('Projections') }

    it 'should create a Select Expression with projections' do
      subject.instance_variable_set(:@projections, projections)
      expect(AgnosticStore::Queryable::Expressions::Select).to receive(:new).with(projections ,subject)
      subject.send(:build_select_expression)
    end
  end

  describe '#build_order_expression' do
    let(:order_qualifiers) { double('order_qualifiers') }

    it 'should create an Order Expression with order_qualifiers' do
      subject.instance_variable_set(:@order_qualifiers, order_qualifiers)
      expect(AgnosticStore::Queryable::Expressions::Order).to receive(:new).with(order_qualifiers ,subject)
      subject.send(:build_order_expression)
    end
  end

  describe '#build_limit_expression' do
    let(:limit) { double('limit') }

    it 'should create a Limit Expression with limit' do
      subject.instance_variable_set(:@limit, limit)
      expect(AgnosticStore::Queryable::Expressions::Limit).to receive(:new).with(limit ,subject)
      subject.send(:build_limit_expression)
    end
  end

  describe '#build_offset_expression' do
    let(:offset) { double('offset') }

    it 'should create an Offset Expression with offset' do
      subject.instance_variable_set(:@offset, offset)
      expect(AgnosticStore::Queryable::Expressions::Offset).to receive(:new).with(offset ,subject)
      subject.send(:build_offset_expression)
    end
  end

  describe '#build_order_qualifier' do
    let(:attribute) { double('Attribute')}
    context 'when direction is :asc' do
      let(:ascending_operation) { double('AscendingOperation')}
      it 'should create and Ascending Operation' do
        expect(AgnosticStore::Queryable::Operations::Ascending).to receive(:new).with(attribute, subject).and_return ascending_operation
        expect(subject.send(:build_order_qualifier, attribute, :asc)).to eq ascending_operation
      end
    end

    context 'when direction is :desc' do
      let(:descending_operation) { double('AscendingOperation')}

      it 'should create and Descending Operation' do
        expect(AgnosticStore::Queryable::Operations::Descending).to receive(:new).with(attribute, subject).and_return descending_operation
        expect(subject.send(:build_order_qualifier, attribute, :desc)).to eq descending_operation
      end
    end
  end
end