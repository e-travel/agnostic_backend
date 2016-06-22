require "spec_helper"
require 'webmock/rspec'

describe AgnosticBackend::Elasticsearch::Client do

  subject { AgnosticBackend::Elasticsearch::Client.new endpoint: host }
  let(:host) { 'http://localhost:9200' }

  describe '#describe_index_fields' do
    context 'when response has a payload' do
      let(:response) do
        {
          'index' => {
            'mappings' => {
              'type' => {
                'properties' => {
                  'field_a' => {'type' => 'integer'},
                  'field_b' => {'type' => 'string' }
                }
              }
            }
          }
        }
      end
      before { stub_request(:get, URI.join(host, "/index/_mapping/type")).
               to_return(body: response.to_json) }

      it 'should return an array of RemoteIndexFields' do
        rfields = subject.describe_index_fields('index', 'type')
        expect(rfields.all?{|rfield| rfield.is_a? AgnosticBackend::Elasticsearch::RemoteIndexField}).
          to be true
        expect(rfields.map(&:type)).to eq [:integer, :string]
      end
    end

    context 'when the response is empty' do
      let(:response) { nil }
      before { stub_request(:get, URI.join(host, "/index/_mapping/type")) }
      it { expect(subject.describe_index_fields('index', 'type')).to be_nil }
    end
  end

  describe '#send_request' do
    let(:path) { "/path" }
    let(:headers) { subject.send(:default_headers) }
    it 'should form the correct request' do
      stub_request(:get, URI.join(host, path)).with(headers: headers)
      subject.send(:send_request, 'GET', path: path, body: nil)
    end

    context 'when the body is supplied as a Hash' do
      let(:body) { {a: 1} }
      it 'should encode it to JSON and use it as payload' do
        stub_request(:post, URI.join(host, path)).with(body: body,
                                                       headers: headers)
        subject.send(:send_request, 'POST', path: path, body: body)
      end
    end

    context 'when the body is supplied as a string' do
      let(:body) { {a: 1} }
      it 'should use it as is for the payload' do
        stub_request(:post, URI.join(host, path)).with(body: body,
                                                       headers: headers)
        subject.send(:send_request, 'POST', path: path, body: body.to_json)
      end
    end
  end
end
