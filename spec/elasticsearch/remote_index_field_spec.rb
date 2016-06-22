require 'spec_helper'

describe AgnosticBackend::Elasticsearch::RemoteIndexField do

  subject { AgnosticBackend::Elasticsearch::RemoteIndexField.new 'the_name',
                                                                 'string',
                                                                 opt: 'optional' }

  describe '#initialize' do
    it 'should discover the local type from the remote' do
      expect(subject.type).to eq AgnosticBackend::Indexable::FieldType::STRING
    end
  end

  describe '#method_missing' do
    context "when the requested method is a key in options hash" do
      it "should return the key's value" do
        expect(subject.opt).to eq 'optional'
      end
    end
    context 'when the requested method is not a key in options hash' do
      it 'should delegate to super' do
        expect { subject.not_a_method }.to raise_error NoMethodError
      end
    end
  end

end
