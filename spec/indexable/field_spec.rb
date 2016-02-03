require 'spec_helper'

describe AgnosticBackend::Indexable::Field do
  subject { AgnosticBackend::Indexable::Field }

  describe '#initialize' do
    context 'when type is not supported ' do
      it 'should raise an exception' do
        expect { subject.new 'hello', :invalid_type }.to raise_error /not supported/
      end
    end

    context 'when type is supported' do
      it 'should create and store a FieldType' do
        field = subject.new 'hello', AgnosticBackend::Indexable::FieldType::INTEGER
        expect(field.type).to be_a AgnosticBackend::Indexable::FieldType
      end
    end

    context 'when the value is a callable' do
      let(:field) { subject.new proc { a_message }, :string }
      it 'should be saved as is' do
        expect(field.value).to be_a Proc
      end
    end

    context 'when the value is not a callable' do
      let(:field) { subject.new 'message', :string }
      it 'should be saved as a symbol' do
        expect(field.value).to eq :message
      end
    end

    context 'when the type is a struct and `from` is not given' do
      it { expect{ subject.new 'message', :struct }.to raise_error /A nested type/}
    end

    context 'when `from` is an enumerable' do
      let(:field) { subject.new 'message', :string, from: [:a]}
      it 'should be saved as is' do
        expect(field.from).to eq [:a]
      end
    end

    context 'when `from` is not an enumerable' do
      let(:field) { subject.new 'message', :string, from: :a}
      it 'should be saved as an enumerable' do
        expect(field.from).to eq [:a]
      end
    end
  end

  describe '#evaluate' do
    let(:object) { double('AnObject') }
    context 'when the value is a symbol' do
      let(:field) { subject.new :alpha, :string }
      it 'should send the value as a message to the object' do
        expect(object).to receive(:alpha)
        field.evaluate(context: object)
      end
    end

    context 'when the value is a callable' do
      let(:field) { subject.new proc { a_message }, :string }
      it 'should call the value in the context of the object' do
        expect(object).to receive(:a_message)
        field.evaluate(context: object)
      end
    end
  end
end
