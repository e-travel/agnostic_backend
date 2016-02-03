require 'spec_helper'

describe AgnosticBackend::Queryable::Cloudsearch::QueryBuilder do
  let(:index) { double('Index') }
  subject { AgnosticBackend::Queryable::Cloudsearch::QueryBuilder.new(index) }

  context 'inheritance' do
    it { should be_a_kind_of(AgnosticBackend::Queryable::QueryBuilder) }
  end

  let(:context) { double('Context') }
  describe '#create_query' do
    it 'should create a cloudsearch query' do
      expect(subject.send(:create_query, context)).to be_a AgnosticBackend::Queryable::Cloudsearch::Query
    end
  end
end