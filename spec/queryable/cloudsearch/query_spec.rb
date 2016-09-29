require 'spec_helper'

describe AgnosticBackend::Queryable::Cloudsearch::Query do
  let(:base) { double('Base') }
  context 'when parser option is set to :simple' do
    subject { AgnosticBackend::Queryable::Cloudsearch::Query.new(base, parser: :simple) }
    it 'should use the SimpleVisitor' do
      expect(subject.executor.visitor).to be_a AgnosticBackend::Queryable::Cloudsearch::SimpleVisitor
    end
  end

  context 'when parser option is not set' do
    subject { AgnosticBackend::Queryable::Cloudsearch::Query.new(base) }
    it 'should use the Visitor' do
      expect(subject.executor.visitor).to be_a AgnosticBackend::Queryable::Cloudsearch::Visitor
    end
  end
end
