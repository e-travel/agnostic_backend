require 'spec_helper'

describe AgnosticBackend::Queryable::Cloudsearch::SimpleVisitor do

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
    describe '#visit_criteria_starts' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::Starts.new(attribute: '*', value: 'value', context: context)}
      it 'should evaluate to value*' do
        expect(subject).to receive(:visit_criteria_starts).and_call_original
        expect(subject.visit(visitor_subject)).to eq "value*"
      end
    end

    describe '#visit_criteria_fuzzy' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::Fuzzy.new(attribute: '*', value: 'value', context: context, fuzziness: 2)}
      it 'should evaluate to value~fuzziness' do
        expect(subject).to receive(:visit_criteria_fuzzy).and_call_original
        expect(subject.visit(visitor_subject)).to eq "value~2"
      end
    end

    describe '#visit_criteria_free_text' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Criteria::FreeText.new(attribute: '*', value: 'value', context: context)}
      it 'should evaluate to value' do
        expect(subject).to receive(:visit_criteria_free_text).and_call_original
        expect(subject.visit(visitor_subject)).to eq "value"
      end
    end
  end

  context 'unary criterion' do
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
      let(:fuzzy_criterion) { AgnosticBackend::Queryable::Criteria::Fuzzy.new(attribute: '*', value: 'abcde', context: context, fuzziness: 2)}
      let(:visitor_subject) { AgnosticBackend::Queryable::Expressions::Where.new(criterion: fuzzy_criterion, context: context)}

      it 'should evaluate to value~fuzziness' do
        expect(subject).to receive(:visit_expressions_where).and_call_original
        expect(subject.visit(visitor_subject)).to eq "abcde~2"
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

  describe '#visit_value' do
    let(:parent) { double('Parent') }

    context 'when attribute\'s type is string' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new('value', parent: parent, context: context)}
      it 'should evaluate to \'value\'' do
        expect(visitor_subject).to receive(:type).and_return(:string)
        expect(subject).to receive(:visit_value).and_call_original
        expect(subject.visit(visitor_subject)).to eq 'value'
      end
    end

    context 'when attribute\'s type is string array' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new('value', parent: parent, context: context)}
      it 'should evaluate to \'value\'' do
        expect(visitor_subject).to receive(:type).and_return(:string_array)
        expect(subject).to receive(:visit_value).and_call_original
        expect(subject.visit(visitor_subject)).to eq 'value'
      end
    end

    context 'when attribute\'s type is text' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new('value', parent: parent, context: context) }
      it 'should evaluate to \'value\'' do
        expect(visitor_subject).to receive(:type).and_return(:text)
        expect(subject).to receive(:visit_value).and_call_original
        expect(subject.visit(visitor_subject)).to eq 'value'
      end
    end

    context 'when attribute\'s type is text array' do
      let(:visitor_subject) { AgnosticBackend::Queryable::Value.new('value', parent: parent, context: context) }
      it 'should evaluate to \'value\'' do
        expect(visitor_subject).to receive(:type).and_return(:text_array)
        expect(subject).to receive(:visit_value).and_call_original
        expect(subject.visit(visitor_subject)).to eq 'value'
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
