require 'spec_helper'

describe AgnosticBackend::Cloudsearch::RemoteIndexField do

  let(:options) { double("Options") }
  let(:status) { double("Status") }
  let(:remote_field_struct) { double("Struct", options: options, status: status) }

  subject { AgnosticBackend::Cloudsearch::RemoteIndexField.new(remote_field_struct) }

  describe '.partition' do
    let(:lf1) { double("LocalField", name: 'field1') }
    let(:lf2) { double("LocalField", name: 'field2') }
    let(:rf1) { double("RemoteField", index_field_name: 'field1') }
    let(:rf2) { double("RemoteField", index_field_name: 'new_field') }

    it 'should separate the remote fields acc. to whether they have corresponding local fields' do
      yes, no = AgnosticBackend::Cloudsearch::RemoteIndexField.partition([lf1,lf2], [rf1,rf2])
      expect(yes.size).to eq 1
      expect(yes.first).to eq rf1
      expect(no.size).to eq 1
      expect(no.first).to eq rf2
    end
  end

  describe '#initialize' do
    it { expect(subject.field).to eq options }
    it { expect(subject.status).to eq status }
  end

  describe '#method_missing' do
    let(:method_name) { :hello }
    context 'when the requested method exists on the object\'s field attribute' do
      before { allow(subject.field).to receive(:respond_to?).with(method_name).and_return(true) }
      it 'should send the message to its field attribute' do
        expect(subject.field).to receive(method_name)
        subject.send(method_name)
      end
    end
    context 'when the requested method does not exist on the object\'s field attribute' do
      before { allow(subject.field).to receive(:respond_to?).with(method_name).and_return(false) }
      it 'should send the message to its field attribute' do
        expect(subject.field).not_to receive(method_name)
        expect{subject.send(method_name)}.to raise_error NoMethodError
      end
    end
  end

end
