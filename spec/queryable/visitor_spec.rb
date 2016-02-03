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

  describe '#class_to_method_name' do
    it 'should prefix visit split the string in Queryable:: and join with _' do
      expect(subject.send(:class_to_method_name, context.class)).to eq 'visit_bar_baz_foo'
    end
  end
end
