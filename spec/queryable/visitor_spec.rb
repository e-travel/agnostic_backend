require 'spec_helper'

describe AgnosticBackend::Queryable::Visitor do

  let(:klass) { double('Class', name: 'Foo::Queryable::Bar::BazFoo')}
  let(:context) { double('Context', class: klass) }

  describe '#visit' do
    it 'should send the method to the context' do
      expect(subject).to receive(:class_to_method_name).with(context.class).and_return('visit_bar_baz')
      expect(subject).to receive(:visit_bar_baz).with(context)
      subject.visit(context)
    end
  end

  describe "Not Implemented methods" do
    it 'should raise an error' do
      not_implemented_method_names.each do |method_name|
        expect{ subject.send(method_name, :params) }.to raise_error { NotImplementedError }
      end
    end

    def not_implemented_method_names
      [
          :visit_operations_equal,
          :visit_operations_not_equal,
          :visit_operations_greater,
          :visit_operations_less,
          :visit_operations_greater_equal,
          :visit_operations_less_equal,
          :visit_operations_greater_and_less,
          :visit_operations_greater_equal_and_less,
          :visit_operations_greater_and_less_equal,
          :visit_operations_greater_equal_and_less_equal,
          :visit_operations_not,
          :visit_operations_and,
          :visit_operations_or,
          :visit_operations_ascending,
          :visit_operations_descending,
          :visit_operations_contains,
          :visit_operations_starts,
          :visit_query,
          :visit_expressions_where,
          :visit_expressions_select,
          :visit_expressions_order,
          :visit_expressions_limit,
          :visit_expressions_offset,
          :visit_expressions_scroll_cursor,
          :visit_attribute,
          :visit_value
      ]
    end
  end
end
