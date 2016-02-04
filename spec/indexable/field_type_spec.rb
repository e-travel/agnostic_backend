require 'spec_helper'

describe AgnosticBackend::Indexable::FieldType do
  subject { AgnosticBackend::Indexable::FieldType }

  describe '.all' do
    it { expect(subject.all).to include :integer }
    it { expect(subject.all).to include :double }
    it { expect(subject.all).to include :string }
    it { expect(subject.all).to include :string_array }
    it { expect(subject.all).to include :text }
    it { expect(subject.all).to include :text_array }
    it { expect(subject.all).to include :date }
    it { expect(subject.all).to include :boolean }
    it { expect(subject.all).to include :struct }
    it { expect(subject.all.size).to eq 9 }
  end

  describe '.exists?' do
    context 'when type exists' do
      it { expect(subject.all.all?{|type| subject.exists? type}).to be_true}
    end
    context 'when type does not exist' do
      it { expect(subject.exists? :hello).to be_false }
    end
  end

  describe '#initialize' do
    it 'should parse the options and convert all keys to strings' do
      ftype = subject.new(subject::INTEGER, :a => 1, :b => 2)
      expect(ftype.instance_variable_get(:@options).keys).to eq [:a, :b]
    end

    context 'when supplied type is not supported' do
      it 'should generate an error' do
        expect{ subject.new(:invalid_type) }.to raise_error 'Type invalid_type not supported'
      end
    end
  end

  describe '#matches?' do
    let(:ftype) { subject.new subject::INTEGER }
    context 'when supplied type matches' do
      it { expect(ftype.matches?(:integer)).to be_true }
    end
    context 'when supplied type does not match' do
      it { expect(ftype.matches?(:something_else)).to be_false }
    end
  end

  describe '#get_option' do
    let(:type) { subject.new subject::INTEGER, an_option: 'option_value' }
    it 'should return the option\'s value' do
      expect(type.get_option(:an_option)).to eq 'option_value'
    end
  end

  describe '#has_option' do
    let(:type) { subject.new subject::INTEGER, an_option: 'option_value' }
    it 'should return true if option contained' do
      expect(type.has_option(:an_option)).to be_true
    end

    it 'should return false if option not contained' do
      expect(type.has_option(:another_option)).to be_false
    end
  end
end
