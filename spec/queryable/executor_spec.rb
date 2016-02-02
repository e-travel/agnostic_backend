require 'spec_helper'

describe AgnosticBackend::Queryable::Executor do

  let(:query) { double('Query') }
  let(:visitor) { double('Visitor') }
  let(:executor) { AgnosticBackend::Queryable::Executor.new(query, visitor)}

  describe '#initialize' do
    it 'should assign the query' do
      expect(executor.query).to eq query
    end

    it 'should assign the visitor' do
      expect(executor.visitor).to eq visitor
    end
  end

  describe '#execute' do
    it 'should raise Exception' do
      expect{executor.execute}.to raise_error(NotImplementedError)
    end
  end
end

