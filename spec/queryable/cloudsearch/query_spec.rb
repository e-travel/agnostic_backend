require 'spec_helper'

describe AgnosticBackend::Queryable::Cloudsearch::Query do
  let(:base) { double('Base') }
  context 'when parser option is set to :simple' do
    subject { AgnosticBackend::Queryable::Cloudsearch::Query.new(base, parser: :simple) }
    it 'should use the SimpleVisitor as query visitor and Visitor as filter visitor' do
      expect(subject.executor.visitor).to be_a AgnosticBackend::Queryable::Cloudsearch::SimpleVisitor
      expect(subject.executor.send(:filter_visitor)).to be_a AgnosticBackend::Queryable::Cloudsearch::Visitor
    end
  end

  context 'when parser option is not set' do
    subject { AgnosticBackend::Queryable::Cloudsearch::Query.new(base) }
    it 'should use the Visitor as query visitor and Visitor as filter visitor' do
      expect(subject.executor.visitor).to be_a AgnosticBackend::Queryable::Cloudsearch::Visitor
      expect(subject.executor.send(:filter_visitor)).to be_a AgnosticBackend::Queryable::Cloudsearch::Visitor
    end
  end
end
