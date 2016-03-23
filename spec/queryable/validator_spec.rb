require 'spec_helper'

describe AgnosticBackend::Queryable::Validator do

  let(:schema) do
    {
        'an_integer' => double('FieldType', type: :integer),
        'a_string' => double('FieldType', type: :string),
        'a_date' => double('FieldType', type: :date)
    }
  end

  let(:index) { double('Index', schema: schema) }
  let(:query) { double('Query', errors: Hash.new{|hash, key| hash[key] = Array.new })}
  let(:context) { double('context', index: index, query: query) }

  let(:parent) do
    class DummyClass; end
    DummyClass.new
  end

  describe "#visit_query" do
    let(:visitor_subject) { AgnosticBackend::Queryable::Query.new(context) }

    let(:child_1) { double('Child') }
    let(:child_2) { double('Child') }

    before do
      visitor_subject.children << child_1
      visitor_subject.children << child_2
    end

    it 'should visit each children' do
      expect(subject).to receive(:visit).with(child_1)
      expect(subject).to receive(:visit).with(child_2)

      result = subject.send(:visit_query, visitor_subject)
      expect(result).to eq subject.instance_variable_get(:@valid)
    end
  end

  describe "Binary Criteria visits" do
    let(:binary_criteria_classes) do
      [
          AgnosticBackend::Queryable::Criteria::Equal,
          AgnosticBackend::Queryable::Criteria::NotEqual,
          AgnosticBackend::Queryable::Criteria::Greater,
          AgnosticBackend::Queryable::Criteria::Less,
          AgnosticBackend::Queryable::Criteria::GreaterEqual,
          AgnosticBackend::Queryable::Criteria::LessEqual,
          AgnosticBackend::Queryable::Criteria::Contains,
          AgnosticBackend::Queryable::Criteria::Starts
      ]
    end

    it 'should visit criterion attribute and value' do
      binary_criteria_classes.each do |criteria_name|
        criteria_instance = criteria_name.new(
            attribute: 'an_integer', value: 1, context: context)

        expect(subject).to receive(:visit).with(criteria_instance).and_call_original
        expect(subject).to receive(:visit).with(criteria_instance.attribute)
        expect(subject).to receive(:visit).with(criteria_instance.value)

        subject.visit(criteria_instance)
      end
    end
  end

  describe "Ternary Criteria Visits" do
    let(:ternary_criteria_classes) do
      [
          AgnosticBackend::Queryable::Criteria::GreaterAndLess,
          AgnosticBackend::Queryable::Criteria::GreaterEqualAndLess,
          AgnosticBackend::Queryable::Criteria::GreaterAndLessEqual,
          AgnosticBackend::Queryable::Criteria::GreaterEqualAndLessEqual
      ]
    end

    it 'should visit criterion attribute left value and right value' do
      ternary_criteria_classes.each do |criteria_name|
        criteria_instance = criteria_name.new(
            attribute: 'an_integer', left_value: 1,right_value: 2, context: context)

        expect(subject).to receive(:visit).with(criteria_instance).and_call_original
        expect(subject).to receive(:visit).with(criteria_instance.attribute)
        expect(subject).to receive(:visit).with(criteria_instance.left_value)
        expect(subject).to receive(:visit).with(criteria_instance.right_value)
        subject.visit(criteria_instance)
      end
    end
  end

  describe "Unary Operations" do
    context "Not operation" do
      it 'should should visit operation\'s operand' do
        operator = AgnosticBackend::Queryable::Operations::Not.new(
            operand: 'operand', context: context)

        expect(subject).to receive(:visit).with(operator).and_call_original
        expect(subject).to receive(:visit).with(operator.operand)
        subject.visit(operator)
      end
    end

    context "OrderQualifier operation" do
      let(:operation_classes) do
        [
            AgnosticBackend::Queryable::Operations::Ascending,
            AgnosticBackend::Queryable::Operations::Ascending
        ]
      end

      it 'should visit operation\'s attribute' do
        operation_classes.each do |class_name|
          operator = class_name.new(attribute: 'a', context: context)

          expect(subject).to receive(:visit).with(operator).and_call_original
          expect(subject).to receive(:visit).with(operator.attribute)
          subject.visit(operator)
        end
      end
    end
  end

  describe "Expressions" do
    context "Where" do
      let(:criteria) do
        AgnosticBackend::Queryable::Criteria::Equal.new(
            attribute: 'an_integer', value: 1, context: context)
      end

      it 'should visit criterion' do
        expression = AgnosticBackend::Queryable::Expressions::Where.new(
            criterion: criteria, context: context)

        expect(subject).to receive(:visit).with(expression).and_call_original
        expect(subject).to receive(:visit).with(expression.criterion)
        subject.visit(expression)
      end
    end

    context "select" do
      let(:projections) { ['an_integer','a_string','a_date'] }
      let(:select_expression) { AgnosticBackend::Queryable::Expressions::Select.new(attributes: [projections], context: context) }

      it 'should visit all projections' do
        expect(subject).to receive(:visit).with(select_expression).and_call_original
        select_expression.projections.each do |projection|
          expect(subject).to receive(:visit).with(projection)
        end
        subject.visit(select_expression)
      end
    end

    context "Order" do
      let(:ascending_qualifier) { AgnosticBackend::Queryable::Operations::Ascending.new(attribute: 'a_string', context: context) }
      let(:descending_qualifier) { AgnosticBackend::Queryable::Operations::Descending.new(attribute: 'an_integer', context: context) }
      let(:order_expression) { AgnosticBackend::Queryable::Expressions::Order.new(attributes: [ascending_qualifier, descending_qualifier], context: context) }
      it 'should visit all qualifiers' do
        expect(subject).to receive(:visit).with(order_expression).and_call_original
        order_expression.qualifiers.each do |qualifier|
          expect(subject).to receive(:visit).with(qualifier)
        end
        subject.visit(order_expression)
      end
    end
    context "Limit" do
      let(:limit) { 1 }
      let(:limit_expression) { AgnosticBackend::Queryable::Expressions::Limit.new(value: limit, context: context) }
      it 'should visit limit' do
        expect(subject).to receive(:visit).with(limit_expression).and_call_original
        expect(subject).to receive(:visit).with(limit_expression.limit)

        subject.visit(limit_expression)
      end
    end
    context "Offset" do
      let(:offset) { 1 }
      let(:offset_expression) { AgnosticBackend::Queryable::Expressions::Offset.new(value: offset, context: context) }
      it 'should visit offset' do
        expect(subject).to receive(:visit).with(offset_expression).and_call_original
        expect(subject).to receive(:visit).with(offset_expression.offset)

        subject.visit(offset_expression)
      end
    end

    context "ScrollCursor" do
      let(:scroll_cursor) { 'foo' }
      let(:scroll_cursor_expression) { AgnosticBackend::Queryable::Expressions::ScrollCursor.new(value: scroll_cursor, context: context) }

      it 'should visit scroll_cursor' do
        expect(subject).to receive(:visit).with(scroll_cursor_expression).and_call_original
        expect(subject).to receive(:visit).with(scroll_cursor_expression.scroll_cursor)

        subject.visit(scroll_cursor_expression)
      end
    end
  end

  describe '#visit_attribute' do
    let(:attribute_name) { 'nested_model.attribute' }
    let(:visitor_subject) { AgnosticBackend::Queryable::Attribute.new(attribute_name, parent: parent, context: context) }

    context 'when schema does not have attribute name as key' do
      before do
        allow(subject).to receive(:value_for_key).with(index.schema, attribute_name).and_return nil
      end

      it 'should append error to query errors' do
        expect(subject).to receive(:visit_attribute).and_call_original
        subject.visit(visitor_subject)
        expect(query.errors).to eq({'AgnosticBackend::Queryable::Attribute'=>['Attribute \'nested_model.attribute\' in DummyClass missing from schema']})
      end

      it 'should change validator state to invalid' do
        expect(subject).to receive(:visit_attribute).and_call_original
        subject.visit(visitor_subject)
        expect(subject.instance_variable_get('@valid')).to be false
      end
    end

    context 'when schema does have attribute name as key' do
      before do
        allow(subject).to receive(:value_for_key).with(index.schema, attribute_name).and_return 'the_attribute'
      end

      it 'should leave query errors empty' do
        expect(subject).to receive(:visit_attribute).and_call_original
        subject.visit(visitor_subject)
        expect(query.errors).to be_empty
      end

      it 'should keep validator state to valid' do
        expect(subject).to receive(:visit_attribute).and_call_original
        subject.visit(visitor_subject)
        expect(subject.instance_variable_get('@valid')).to be true
      end
    end
  end

  describe '#visit_value' do
    let(:attribute_name) { 'nested_model.attribute' }
    let(:associated_attribute) { AgnosticBackend::Queryable::Attribute.new(attribute_name, parent: parent, context: context) }

    context 'when value does not have the required type' do
      context ':integer type' do
        let(:value) { '1' }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:integer)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as integer type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be false
        end
      end

      context ':double type' do
        let(:value) { 5 }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:double)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as double type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be false
        end
      end

      context ':string type' do
        let(:value) { 1 }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:string)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as string type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be false
        end
      end

      context ':string_array type' do
        let(:value) { 1.23 }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:string_array)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as string_array type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be false
        end
      end

      context ':text type' do
        let(:value) { true }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:text)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as text type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be false
        end
      end

      context ':text_array type' do
        let(:value) { DateTime.now }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:text_array)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as text_array type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be false
        end
      end

      context ':date type' do
        let(:value) { '01-01-2016' }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:date)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as date type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be false
        end
      end

      context ':boolean type' do
        let(:value) { 'true' }
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

        before do
          allow(visitor_subject).to receive(:type).and_return(:boolean)
          allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
        end

        it 'should append error to query errors' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(query.errors).to eq({'AgnosticBackend::Queryable::Value'=>["Value #{value} for nested_model.attribute in DummyClass is defined as boolean type in schema"]})
        end

        it 'should change validator state to invalid' do
          expect(subject).to receive(:visit_value).and_call_original
          subject.visit(visitor_subject)
          expect(subject.instance_variable_get('@valid')).to be false
        end
      end
    end

    context 'when value has the required type' do
      let(:value) { 1 }
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

      before do
        allow(visitor_subject).to receive(:type).and_return(:integer)
        allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
      end

      it 'should append error to query errors' do
        expect(subject).to receive(:visit_value).and_call_original
        subject.visit(visitor_subject)
        expect(query.errors).to be_empty
      end

      it 'should change validator state to invalid' do
        expect(subject).to receive(:visit_value).and_call_original
        subject.visit(visitor_subject)
        expect(subject.instance_variable_get('@valid')).to be true
      end
    end

    context 'when value has not type' do
      let(:value) { 1 }
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context) }

      before do
        allow(visitor_subject).to receive(:type).and_return(nil)
        allow(visitor_subject).to receive(:associated_attribute).and_return(associated_attribute)
      end

      it 'should append error to query errors' do
        expect(subject).to receive(:visit_value).and_call_original
        subject.visit(visitor_subject)
        expect(query.errors).to be_empty
      end

      it 'should change validator state to invalid' do
        expect(subject).to receive(:visit_value).and_call_original
        subject.visit(visitor_subject)
        expect(subject.instance_variable_get('@valid')).to be true
      end
    end
  end
end
