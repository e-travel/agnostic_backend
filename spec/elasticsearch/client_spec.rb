require "spec_helper"
require 'webmock/rspec'

describe AgnosticBackend::Elasticsearch::Client do

  subject { AgnosticBackend::Elasticsearch::Client.new endpoint: host }
  let(:host) { 'http://localhost:9200' }

  describe '#describe_index_fields' do
    skip
  end

  describe '#send_request' do
    let(:path) { "/path" }
    let(:headers) { subject.send(:default_headers) }
    it 'should form the correct request' do
      stub_request(:get, URI.join(host, path)).with(headers: headers)
      subject.send(:send_request, 'GET', path: path, body: nil)
    end

    context 'when a body is specified' do
      let(:body) { {a: 1} }
      it 'should encode it to JSON' do
        stub_request(:post, URI.join(host, path)).with(body: body,
                                                       headers: headers)
        subject.send(:send_request, 'POST', path: path, body: body)
      end
    end
  end
end
