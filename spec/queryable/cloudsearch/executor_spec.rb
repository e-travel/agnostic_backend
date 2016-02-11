require 'spec_helper'

describe AgnosticBackend::Queryable::Cloudsearch::Executor do

  before do
    Object.send(:remove_const, :QueryableObject) if Object.constants.include? :QueryableObject
    class QueryableObject;
    end
    QueryableObject.send(:include, AgnosticBackend::Queryable)

    allow_any_instance_of(AgnosticBackend::Cloudsearch::Index).to receive(:parse_option)
    allow(index).to receive(:schema).and_return({'a' => :integer,  'b' => :integer, 'c' => :string, 'd' => :string})
    allow(index).to receive(:search_endpoint).and_return('http://endpoint')
    allow(index).to receive(:query_builder).and_return(builder)
    allow(QueryableObject).to receive(:create_index).and_return(index)
  end

  let(:index) { AgnosticBackend::Cloudsearch::Index.new(QueryableObject) }
  let(:builder) { AgnosticBackend::Queryable::Cloudsearch::QueryBuilder.new(index) }
  let(:context) { double("Context", index: index) }
  let(:query) { double("Query", base: builder, context: context) }
  let(:visitor) { double('Visitor') }

  subject { AgnosticBackend::Queryable::Cloudsearch::Executor.new(query, visitor)}

  describe '#execute' do
    let(:client) { double("Client") }
    let(:params) { { params: 'query_params' } }
    let(:response) { double("Response") }
    it 'should construct an aws cloudsearch domain client ' do
      allow(subject).to receive(:client).and_return client
      expect(subject).to receive(:params).and_return(params)
      expect(client).to receive(:search).with(params).and_return response
      expect(AgnosticBackend::Queryable::Cloudsearch::ResultSet).to receive(:new).with(response, query)
      subject.execute
    end
  end

  describe '#client' do
    it "should return a CloudSearch concrete client" do
      allow(query).to receive(:index).and_return(index)
      expect(index).to receive(:cloudsearch_domain_client)
      subject.send(:client)
    end
  end

  describe '#filter_query' do
  end

  describe '#query_expression' do
    it 'should return where clause evaluation' do
      where_expression = double('WhereExpression')
      expect(subject).to receive(:where_expression).twice.and_return(where_expression)
      expect(where_expression).to receive(:accept).with(visitor).and_return('(field=attribute value)')
      expect(subject.send(:query_expression)).to eq '(field=attribute value)'
    end
  end

  describe '#start' do
    it 'should return where offset clause evaluation' do
      offset = double('Offset')
      expect(subject).to receive(:offset_expression).twice.and_return(offset)
      expect(offset).to receive(:accept).with(visitor).and_return(1)
      expect(subject.send(:start)).to eq 1
    end
  end

  describe '#cursor' do
  end

  describe '#expr' do
  end

  describe '#facet' do
  end

  describe '#highlight' do
  end

  describe '#partial' do
    it 'should return false' do
      expect(subject.send(:partial)).to be_false
    end
  end

  describe '#query_options' do
  end

  describe '#query_parser' do
    it 'should return \'structured\'' do
      expect(subject.send(:query_parser)).to eq 'structured'
    end
  end

  describe '#return_expression' do
    it 'should return where clause evaluation' do
      select_expression = double('SelectExpression')
      expect(subject).to receive(:select_expression).twice.and_return(select_expression)
      expect(select_expression).to receive(:accept).with(visitor).and_return('(attribute_1, attribute_2)')
      expect(subject.send(:return_expression)).to eq '(attribute_1, attribute_2)'
    end
  end

  describe '#size' do
    it 'should return where limit evaluation' do
      limit_expression = double('LimitExpression')
      expect(subject).to receive(:limit_expression).twice.and_return(limit_expression)
      expect(limit_expression).to receive(:accept).with(visitor).and_return 10
      expect(subject.send(:size)).to eq 10
    end
  end

  describe '#sort' do
    it 'should return where order clause evaluation' do
      order_expression = double('OrderExpression')
      expect(subject).to receive(:order_expression).twice.and_return(order_expression)
      expect(order_expression).to receive(:accept).with(visitor).and_return('attribute_1 asc, attribute_2')
      expect(subject.send(:sort)).to eq 'attribute_1 asc, attribute_2'
    end
  end
end
