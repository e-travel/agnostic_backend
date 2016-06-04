require 'spec_helper'

describe AgnosticBackend::Queryable::Elasticsearch::ResultSet do

  subject do
    AgnosticBackend::Queryable::Elasticsearch::ResultSet.new(raw_results, query)
  end

  let(:raw_results) do
    {
      "_shards"=>{
        "total" => 5,
        "successful" => 5,
        "failed" => 0
      },
      "hits" =>{
        "total" => 2,
        "hits" => [
          {
            "_index" => "index",
            "_type" => "type",
            "_id" => "1",
            "fields" => {
              "a__b" => [1],
              "a__b__c" => [2],
              "d" => [3],
              "e" => [4, 5, 6]
            }
          },
          {
            "_index" => "index",
            "_type" => "type",
            "_id" => "1",
            "fields" => {
              "a__b" => [7],
              "a__b__c" => [8],
              "d" => [9],
              "e" => [10, 11, 12]
            }
          }
        ]
      },
      "_scroll_id" => "scroll"
    }
  end

  let(:query) { double('query') }

  describe '#total_count' do
    it 'should be return total from hits' do
      expect(subject.total_count).to eq 2
    end
  end

  describe '#cursor' do
    it 'should be cursor attribute from raw_results.hits when cursor present' do
      expect(subject.scroll_cursor).to eq 'scroll'
    end
  end

  describe '#filtered_results' do
    it 'should be fields mapped from raw_results.hits.hit' do
      expect(subject.send(:filtered_results)).to eq [
        {"a__b"=>[1], "a__b__c"=>[2], "d"=>[3], "e"=>[4, 5, 6]},
        {"a__b"=>[7], "a__b__c"=>[8], "d"=>[9], "e"=>[10, 11, 12]}
      ]
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
