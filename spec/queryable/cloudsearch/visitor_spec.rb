require 'spec_helper'

describe AgnosticBackend::Queryable::Cloudsearch::Visitor do

  let(:schema) do
    {
      'an_integer' => double('FieldType', type: :integer),
      'a_string' => double('FieldType', type: :string),
      'a_date' => double('FieldType', type: :date)
    }
  end
  let(:index) { double('Index', schema: schema) }
  let(:context) { double('Context', index: index) }

  context 'binary criterion' do

    describe '#visit_criteria_equal' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::Equal.new(attribute: 'a_string', value: 'value', context: context)}
      it 'should evaluate to (field=attribute value)' do
        expect(subject).to receive(:visit_criteria_equal).and_call_original
        expect(subject.visit(visitor_subject)).to eq "(term field=a_string 'value')"
      end
    end

    describe '#visit_criteria_free_text' do
      context 'when searching on specific attribute' do
        let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::FreeText.new(attribute: 'a_string', value: 'value', context: context)}
        it 'should evaluate to (and attribute: value)' do
          expect(subject).to receive(:visit_criteria_free_text).and_call_original
          expect(subject.visit(visitor_subject)).to eq "(and a_string: 'value')"
        end
      end

      context 'when searching on any attribute' do
        let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::FreeText.new(attribute: '*', value: 'value', context: context)}
        it 'should evaluate to (and value)' do
          expect(subject).to receive(:visit_criteria_free_text).and_call_original
          expect(subject.visit(visitor_subject)).to eq "(and 'value')"
        end
      end
    end

    describe '#visit_criteria_notequal' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::NotEqual.new(attribute: 'a_string', value: 'value', context: context)}
      it 'should evaluate to (not term field=attribute value)' do
        expect(subject).to receive(:visit_criteria_not_equal).and_call_original
        expect(subject.visit(visitor_subject)).to eq "(not term field=a_string 'value')"
      end
    end

    describe '#visit_criteria_greater' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::Greater.new(attribute: 'an_integer', value: 10, context: context)}
      it 'should evaluate to (range field=attribute {value,})' do
        expect(subject).to receive(:visit_criteria_greater).and_call_original
        expect(subject.visit(visitor_subject)).to eq "(range field=an_integer {10,})"
      end
    end

    describe '#visit_criteria_less' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::Less.new(attribute: 'an_integer', value: 10, context: context)}
      it 'should evaluate to (range field=attribute {value,})' do
        expect(subject).to receive(:visit_criteria_less).and_call_original
        expect(subject.visit(visitor_subject)).to eq '(range field=an_integer {,10})'
      end
    end

    describe '#visit_criteria_greaterequal' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::GreaterEqual.new(attribute: 'an_integer', value: 10, context: context)}
      it 'should evaluate to (range field=attribute [value,})' do
        expect(subject).to receive(:visit_criteria_greater_equal).and_call_original
        expect(subject.visit(visitor_subject)).to eq '(range field=an_integer [10,})'
      end
    end

    describe '#visit_criteria_lessequal' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::LessEqual.new(attribute: 'an_integer', value: 10, context: context)}
      it 'should evaluate to (range field=attribute {value,])' do
        expect(subject).to receive(:visit_criteria_less_equal).and_call_original
        expect(subject.visit(visitor_subject)).to eq '(range field=an_integer {,10])'
      end
    end

    describe '#visit_criteria_contains' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::Contains.new(attribute: 'a_string', value: 'value', context: context)}
      it 'should evaluate to (phrase field=attribute value]' do
        expect(subject).to receive(:visit_criteria_contains).and_call_original
        expect(subject.visit(visitor_subject)).to eq "(phrase field=a_string 'value')"
      end
    end

    describe '#visit_criteria_starts' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::Starts.new(attribute: 'a_string', value: 'value', context: context)}
      it 'should evaluate to (prefix field=attribute value]' do
        expect(subject).to receive(:visit_criteria_starts).and_call_original
        expect(subject.visit(visitor_subject)).to eq "(prefix field=a_string 'value')"
      end
    end
  end

  context 'unary criterion' do
    describe '#visit_operations_not' do
      let(:operand) { AgnosticBackend::Queryable::Criteria::Equal.new(attribute: 'a_string', value: 'value', context: context)}
      let(:visitor_subject) { AgnosticBackend::Queryable::Operations::Not.new(operand: operand, context: context)}
      it 'should evaluate to (not operand)' do
        expect(subject).to receive(:visit_operations_not).and_call_original
        expect(subject.visit(visitor_subject)).to eq "(not (term field=a_string 'value'))"
      end
    end

    describe '#visit_operations_ascending' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Operations::Ascending.new(attribute: 'an_integer', context: context)}
      it 'should evaluate to attribute asc' do
        expect(subject).to receive(:visit_operations_ascending).and_call_original
        expect(subject.visit(visitor_subject)).to eq 'an_integer asc'
      end
    end

    describe '#visit_operations_descending' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Operations::Descending.new(attribute: 'an_integer', context: context)}
      it 'should evaluate to attribute desc' do
        expect(subject).to receive(:visit_operations_descending).and_call_original
        expect(subject.visit(visitor_subject)).to eq 'an_integer desc'
      end
    end
  end

  context 'n-ary expressions' do
    let(:the_date) { DateTime.now }
    let(:left_operand) { AgnosticBackend::Queryable::Criteria::Equal.new(attribute: 'an_integer', value: 10, context: context)}
    let(:center_operand) { AgnosticBackend::Queryable::Criteria::Equal.new(attribute: 'a_string', value: 'value', context: context)}
    let(:right_operand) { AgnosticBackend::Queryable::Criteria::Equal.new(attribute: 'a_date', value: the_date, context: context)}

    describe '#visit_operations_and' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Operations::And.new(operands: [left_operand, center_operand, right_operand], context: context)}

      it 'should evaluate to (and operator_1 operator_2 operator_3)' do
        expect(subject).to receive(:visit_operations_and).and_call_original
        expect(subject.visit(visitor_subject)).to eq "(and (term field=an_integer 10) (term field=a_string 'value') (term field=a_date '#{the_date.utc.strftime("%Y-%m-%dT%H:%M:%SZ")}'))"
      end
    end

    describe '#visit_operations_or' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Operations::Or.new(operands: [left_operand, center_operand, right_operand], context: context)}

      it 'should evaluate to (or operator_1 operator_2 operator_3)' do
        expect(subject).to receive(:visit_operations_or).and_call_original
        expect(subject.visit(visitor_subject)).to eq "(or (term field=an_integer 10) (term field=a_string 'value') (term field=a_date '#{the_date.utc.strftime("%Y-%m-%dT%H:%M:%SZ")}'))"
      end
    end
  end

  context 'ternary criteria' do
    describe '#visit_criteria_greaterandless' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::GreaterAndLess.new(attribute: 'an_integer', left_value: 5, right_value: 10, context: context)}

      it 'should evaluate to (range field=attribute {left_value,right_value})' do
        expect(subject).to receive(:visit_criteria_greater_and_less).and_call_original
        expect(subject.visit(visitor_subject)).to eq'(range field=an_integer {5,10})'
      end
    end

    describe '#visit_criteria_greaterequalandless' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::GreaterEqualAndLess.new(attribute: 'an_integer', left_value: 5, right_value: 10, context: context)}

      it 'should evaluate to (range field=attribute [left_value,right_value})' do
        expect(subject).to receive(:visit_criteria_greater_equal_and_less).and_call_original
        expect(subject.visit(visitor_subject)).to eq '(range field=an_integer [5,10})'
      end
    end

    describe '#visit_criteria_greaterandlessequal' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::GreaterAndLessEqual.new(attribute: 'an_integer', left_value: 5, right_value: 10, context: context)}

      it 'should evaluate to (range field=attribute {left_value,right_value])' do
        expect(subject).to receive(:visit_criteria_greater_and_less_equal).and_call_original
        expect(subject.visit(visitor_subject)).to eq '(range field=an_integer {5,10])'
      end
    end

    describe '#visit_criteria_greaterequalandlessequal' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::GreaterEqualAndLessEqual.new(attribute: 'an_integer', left_value: 5, right_value: 10, context: context)}

      it 'should evaluate to (range field=attribute [left_value,right_value])' do
        expect(subject).to receive(:visit_criteria_greater_equal_and_less_equal).and_call_original
        expect(subject.visit(visitor_subject)).to eq '(range field=an_integer [5,10])'
      end
    end
  end


  describe '#visit_query' do
    let(:base) { double('Base') }
    let(:child_1) { double('child_1', children: []) }
    let(:child_2) { double('child_2', children: []) }

    before do
      allow(subject).to receive(:visit).with(any_args).and_call_original
      allow(subject).to receive(:visit).with(child_1).and_return 'child_1'
      allow(subject).to receive(:visit).with(child_2).and_return 'child_2'
    end

    it 'should evaluate to child1 child2 child3' do
      visitor_subject = AgnosticBackend::Queryable::Query.new(base)
      visitor_subject.children << child_1
      visitor_subject.children << child_2
      expect(subject).to receive(:visit_query).and_call_original
      expect(subject.visit(visitor_subject)).to eq 'child_1 child_2'
    end
  end

  context 'expressions' do

    describe '#visit_expressions_where' do
      let(:an_equal_criterion) { AgnosticBackend::Queryable::Criteria::Equal.new(attribute: 'an_integer', value: 10, context: context)}
      let(:a_not_equal_criterion) { AgnosticBackend::Queryable::Criteria::NotEqual.new(attribute: 'a_string', value: 'value', context: context)}
      let(:and_criterion) { AgnosticBackend::Queryable::Operations::And.new(operands: [an_equal_criterion, a_not_equal_criterion], context: context)}
      let(:visitor_subject) { AgnosticBackend::Queryable::Expressions::Where.new(criterion: and_criterion, context: context)}

      it 'should evaluate to (and (criteria_1) (criteria_2))' do
        expect(subject).to receive(:visit_expressions_where).and_call_original
        expect(subject.visit(visitor_subject)).to eq "(and (term field=an_integer 10) (not term field=a_string 'value'))"
      end
    end

    describe '#visit_expressions_select' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Expressions::Select.new(attributes: ['an_integer','a_string','a_date'], context: context)}

      it 'should evaluate to projection1,projection2,projection3' do
        expect(subject).to receive(:visit_expressions_select).and_call_original
        expect(subject.visit(visitor_subject)).to eq 'an_integer,a_string,a_date'
      end
    end

    describe '#visit_expressions_order' do
      let(:qualifiers_1) { AgnosticBackend::Queryable::Operations::Ascending.new(attribute: 'an_integer', context: context)}
      let(:qualifiers_2) { AgnosticBackend::Queryable::Operations::Descending.new(attribute: 'a_string', context: context)}
      let(:visitor_subject) { AgnosticBackend::Queryable::Expressions::Order.new(attributes: [qualifiers_1, qualifiers_2], context: context)}

      it 'should evaluate to ordering1,ordering2,ordering3' do
        expect(subject).to receive(:visit_expressions_order).and_call_original
        expect(subject.visit(visitor_subject)).to eq 'an_integer asc,a_string desc'
      end
    end

    describe '#visit_expressions_limit' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Expressions::Limit.new(value: 10, context: context)}

      it 'should evaluate to value' do
        expect(subject).to receive(:visit_expressions_limit).and_call_original
        expect(subject.visit(visitor_subject)).to eq 10
      end
    end

    describe '#visit_expressions_offset' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Expressions::Offset.new(value: 10, context: context)}

      it 'should evaluate to size=1' do
        expect(subject).to receive(:visit_expressions_offset).and_call_original
        expect(subject.visit(visitor_subject)).to eq 10
      end
    end

    describe '#visit_cloudsearch_expressions_cursor' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Expressions::ScrollCursor.new(value: 'scroll_cursor', context: context)}

      it 'should evaluate to cursor=abcdef' do
        expect(subject).to receive(:visit_expressions_scroll_cursor).and_call_original
        expect(subject.visit(visitor_subject)).to eq 'scroll_cursor'
      end
    end
  end

  describe '#visit_attribute' do
    let(:parent) { double('Parent') }

    context 'when attribute is not nested' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Attribute.new('attribute', parent: parent, context: context) }
      it 'should evaluate to attribute name' do
        expect(subject).to receive(:visit_attribute).and_call_original
        expect(subject.visit(visitor_subject)).to eq 'attribute'
      end
    end

    context 'when attribute is nested' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Attribute.new('base_attribute.nested_attribute', parent: parent, context: context) }
      it 'should evaluate to attribute name joined with \'__\'' do
        expect(subject).to receive(:visit_attribute).and_call_original
        expect(subject.visit(visitor_subject)).to eq 'base_attribute__nested_attribute'
      end
    end
  end

  describe '#visit_value' do
    let(:parent) { double('Parent') }

    context 'when attribute\'s type is integer' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(10, parent: parent, context: context)}
      it 'should evaluate to value' do
        expect(visitor_subject).to receive(:type).and_return(:integer)
        expect(subject).to receive(:visit_value).and_call_original
        expect(subject.visit(visitor_subject)).to eq 10
      end
    end

    context 'when attribute\'s type is string' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new('value', parent: parent, context: context)}
      it 'should evaluate to \'value\'' do
        expect(visitor_subject).to receive(:type).and_return(:string)
        expect(subject).to receive(:visit_value).and_call_original
        expect(subject.visit(visitor_subject)).to eq '\'value\''
      end
    end

    context 'when attribute\'s type is string array' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new('value', parent: parent, context: context)}
      it 'should evaluate to \'value\'' do
        expect(visitor_subject).to receive(:type).and_return(:string_array)
        expect(subject).to receive(:visit_value).and_call_original
        expect(subject.visit(visitor_subject)).to eq '\'value\''
      end
    end

    context 'when attribute\'s type is date' do
      let(:value) { DateTime.now }
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(value, parent: parent, context: context)}
      it 'should evaluate to date in utc in ISO 8601 format' do
        expect(visitor_subject).to receive(:type).and_return(:date)
        expect(subject).to receive(:visit_value).and_call_original
        expect(subject.visit(visitor_subject)).to eq "'#{value.utc.strftime('%Y-%m-%dT%H:%M:%SZ')}'"
      end
    end

    context 'when attribute\'s type is double' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(10.5, parent: parent, context: context)}
      it 'should evaluate to value' do
        expect(visitor_subject).to receive(:type).and_return(:double)
        expect(subject).to receive(:visit_value).and_call_original
        expect(subject.visit(visitor_subject)).to eq 10.5
      end
    end

    context 'when attribute\'s type is boolean' do
      context 'when value is true' do
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(true, parent: parent, context: context) }
        it 'should evaluate to \'true\'' do
          expect(visitor_subject).to receive(:type).and_return(:boolean)
          expect(subject).to receive(:visit_value).and_call_original
          expect(subject.visit(visitor_subject)).to eq '\'true\''
        end
      end

      context 'when value is false' do
        let(:visitor_subject) { AgnosticBackend::Queryable::Value.new(false, parent: parent, context: context) }
        it 'should evaluate to \'false\'' do
          expect(visitor_subject).to receive(:type).and_return(:boolean)
          expect(subject).to receive(:visit_value).and_call_original
          expect(subject.visit(visitor_subject)).to eq '\'false\''
        end
      end
    end

    context 'when attribute\'s type is text' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new('value', parent: parent, context: context) }
      it 'should evaluate to \'value\'' do
        expect(visitor_subject).to receive(:type).and_return(:text)
        expect(subject).to receive(:visit_value).and_call_original
        expect(subject.visit(visitor_subject)).to eq '\'value\''
      end
    end

    context 'when attribute\'s type is text array' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new('value', parent: parent, context: context) }
      it 'should evaluate to \'value\'' do
        expect(visitor_subject).to receive(:type).and_return(:text_array)
        expect(subject).to receive(:visit_value).and_call_original
        expect(subject.visit(visitor_subject)).to eq '\'value\''
      end
    end

    context 'when attribute\'s type is not defined' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new('value', parent: parent, context: context) }
      it 'should evaluate to value' do
        expect(visitor_subject).to receive(:type).and_return(nil)
        expect(subject).to receive(:visit_value).and_call_original
        expect(subject.visit(visitor_subject)).to eq 'value'
      end
    end
  end
end
