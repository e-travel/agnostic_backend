require 'spec_helper'

describe AgnosticBackend::Queryable::Executor do

  let(:schema) do
    {
        'an_integer' => double('FieldType', type: :integer),
        'a_string' => double('FieldType', type: :string),
        'a_date' => double('FieldType', type: :date)
    }
  end

  let(:index) { double('Index', schema: schema) }
  let(:query) { AgnosticBackend::Queryable::Query.new(context) }
  let(:context) { double('context', index: index) }
  let(:visitor) { double('Visitor') }

  subject do
    AgnosticBackend::Queryable::Executor.new(query, visitor)
  end

  describe '#initialize' do
    it 'should assign the query' do
      expect(subject.query).to eq query
    end

    it 'should assign the visitor' do
      expect(subject.visitor).to eq visitor
    end
  end

  describe '#execute' do
    it 'should raise Exception' do
      expect{subject.execute}.to raise_error(NotImplementedError)
    end
  end

  describe "#order_expression" do
    let(:order_expression) { AgnosticBackend::Queryable::Expressions::Order.new(attributes: ['attr1', 'attr2'], context: context) }
    context "when an order expression is included in query's children" do
      before do
        subject.query.children << order_expression
      end

      it 'should return the order expression' do
        result = subject.send :order_expression
        expect(result).to eq(order_expression)
      end
    end
    context "when an order expression is not included in query's children" do
      it 'should not return the order expression' do
        result = subject.send :order_expression
        expect(result).to be_nil
      end
    end
  end

  describe "#where_expression" do
    let(:criteria) do
      AgnosticBackend::Queryable::Criteria::Equal.new(attribute: 'an_integer', value: 1, context: context)
    end
    let(:where_expression) { AgnosticBackend::Queryable::Expressions::Where.new(criterion: criteria, context: context) }
    context "when a where expression is included in query's children" do
      before do
        subject.query.children << where_expression
      end

      it 'should return the where expression' do
        result = subject.send :where_expression
        expect(result).to eq(where_expression)
      end
    end
    context "when a where expression is not included in query's children" do
      it 'should not return the where expression' do
        result = subject.send :where_expression
        expect(result).to be_nil
      end
    end
  end

  describe "#select_expression" do
    let(:select_expression) { AgnosticBackend::Queryable::Expressions::Select.new(attributes: ['attr1', 'attr2'], context: context) }
    context "when a select expression is included in query's children" do
      before do
        subject.query.children << select_expression
      end

      it 'should return the select expression' do
        result = subject.send :select_expression
        expect(result).to eq(select_expression)
      end
    end
    context "when a select expression is not included in query's children" do
      it 'should not return the select expression' do
        result = subject.send :select_expression
        expect(result).to be_nil
      end
    end
  end

  describe "#limit_expression" do
    let(:limit_expression) { AgnosticBackend::Queryable::Expressions::Limit.new(value: 1, context: context) }
    context "when a limit expression is included in query's children" do
      before do
        subject.query.children << limit_expression
      end

      it 'should return the limit expression' do
        result = subject.send :limit_expression
        expect(result).to eq(limit_expression)
      end
    end
    context "when a limit expression is not included in query's children" do
      it 'should not return the limit expression' do
        result = subject.send :limit_expression
        expect(result).to be_nil
      end
    end
  end

  describe "#offset_expression" do
    let(:offset_expression) { AgnosticBackend::Queryable::Expressions::Offset.new(value: 100, context: context) }
    context "when an offset expression is included in query's children" do
      before do
        subject.query.children << offset_expression
      end

      it 'should return the offset expression' do
        result = subject.send :offset_expression
        expect(result).to eq(offset_expression)
      end
    end
    context "when an offset expression is not included in query's children" do
      it 'should not return the offset expression' do
        result = subject.send :offset_expression
        expect(result).to be_nil
      end
    end
  end

  describe "#scroll_cursor_expression" do
    let(:scroll_cursor_expression) { AgnosticBackend::Queryable::Expressions::ScrollCursor.new(value: 123, context: context) }

    context "when a scroll cursor expression is included in query's children" do
      before do
        subject.query.children << scroll_cursor_expression
      end

      it 'should return the scroll cursor expression' do
        result = subject.send :scroll_cursor_expression
        expect(result).to eq(scroll_cursor_expression)
      end
    end
    context "when a scroll cursor is not included in query's children" do
      it 'should not return the scroll cursor expression' do
        result = subject.send :scroll_cursor_expression
        expect(result).to be_nil
      end
    end
  end


end

