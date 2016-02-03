require 'spec_helper'

describe AgnosticBackend::Queryable::Cloudsearch::ResultSet do

  subject do
    AgnosticBackend::Queryable::Cloudsearch::ResultSet.new(raw_results, query)
  end

  let(:raw_results) { double('raw_results')}
  let(:query) { double('query') }
  let(:hits) { double('hits') }

  before do
    allow(raw_results).to receive(:hits).and_return hits
  end

  describe '#total_count' do
    it 'should be found attribute from raw_results.hits' do
      expect(hits).to receive(:found).and_return 10
      expect(subject.total_count).to eq 10
    end
  end

  describe '#cursor' do
    it 'should be cursor attribute from raw_results.hits when cursor present' do
      expect(hits).to receive(:cursor).and_return 'abcdef'
      expect(subject.cursor).to eq 'abcdef'
    end
  end

  describe '#filtered_results' do
    hit = Struct.new(:fields)
    let(:hit_1) { hit.new([ {'a' => 1}, {'b' => 2}])}
    let(:hit_2) { hit.new([ {'a' => 3}, {'b' => 4}])}

    it 'should be fields mapped from raw_results.hits.hit' do
      expect(raw_results).to receive(:hits).and_return hits
      expect(hits).to receive(:hit).and_return [hit_1, hit_2]
      expect(subject.send(:filtered_results)).to eq [[{'a'=>1}, {'b'=>2}], [{'a'=>3}, {'b'=>4}]]
    end
  end

  describe '#transform' do
    let(:result) do
      {
        'a__b' => [1],
        'a__b__c' => [2],
        'd' => [3],
        'e' => [4, 5, 6]
      }
    end

    it 'should unflatten result and transform values.' do
      expect(subject.send(:transform, result)).to eq(
        {
          'a' =>
          { 'b' => 1,
            'b' => {
            'c' => 2
          }
          },
          'd' => 3,
          'e' => '4|5|6'
        }
      )
    end
  end
end
