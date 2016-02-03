require 'spec_helper'

describe AgnosticBackend::Indexable::ContentManager do
  subject { AgnosticBackend::Indexable::ContentManager.new }

  describe '#add_definitions' do
    let(:field_block) { Proc.new { field :a } }
    it 'should execute the supplied block' do
      expect(subject).to receive(:field).with(:a)
      subject.add_definitions &field_block
    end
  end

  describe '#method_missing' do
    context 'when the method name is a field type' do
      before { allow(AgnosticBackend::Indexable::FieldType).to receive(:exists?).and_return true }
      it 'should add the field to the contents' do
        expect(subject).to receive(:field).with(:field_name, {value: nil, type: :foo}).
                            and_call_original
        subject.send(:foo, :field_name, value: nil, type: :foo)
      end
    end

    context 'when the method name is not a field type' do
      before { allow(AgnosticBackend::Indexable::FieldType).to receive(:exists?).and_return false }
      it 'should forward the message to its superclass' do
        expect { subject.send(:foo, :arg1, kwarg1: :hello) }.to raise_error NoMethodError
      end
    end
  end

  describe '#respond_to?' do
    context 'when sym is a Field type' do
      it { expect(AgnosticBackend::Indexable::FieldType.all.all?{|type| subject.respond_to? type })
           .to be_true }
    end

    context 'when sym is an instance method' do
      it { expect(subject.class.instance_methods(false).all?{|method| subject.respond_to? method}).
           to be_true }
    end

    context 'when sym is none of the above' do
      it { expect(subject.respond_to? :hey_there).to be_false }
    end
  end

  describe '#field' do
    context 'when value: is nil' do
      it 'should add a Field with field_name into the hash' do
        expect(AgnosticBackend::Indexable::Field).
          to receive(:new).with(:a, :integer, {:from=>nil}).
              and_call_original
        subject.field(:a, type: :integer)
        expect(subject.contents['a']).to be_a AgnosticBackend::Indexable::Field
      end
    end

    context 'when value: is present' do
      it 'should add a Field with the value into the hash' do
        expect(AgnosticBackend::Indexable::Field).
          to receive(:new).with(:b, :text, {:from=>nil}).
              and_call_original
        subject.field(:a, value: :b, type: :text)
        expect(subject.contents['a']).to be_a AgnosticBackend::Indexable::Field
      end
    end
  end

  describe '#extract_contents_from' do
    before { subject.add_definitions &(Proc.new { string :a }) }
    let(:object) { double('Object') }
    it 'should evaluate the field\'s value in the context of the object' do
      field = subject.contents['a']
      expect(field).to receive(:evaluate).with(context: object)
      contents = subject.extract_contents_from(object, :index_name)
      expect(contents).to have_key 'a'
    end

    context 'when field is struct (aka nested)' do
      let(:child) { double('Child') }
      before { subject.add_definitions &(Proc.new { struct :a, from: :some_class }) }

      context 'when field value is present' do
        before { allow(object).to receive(:a).and_return child }
        context 'when the field value responds to #generate_document' do
          it 'should generate a document for the nested field (struct)' do
            expect(child).to receive(:generate_document).with(for_index: :index_name)
            contents = subject.extract_contents_from(object, :index_name)
            expect(contents).to have_key 'a'
          end
        end

        context 'when the field value does not respond to #generate_document' do
          before do
            allow(child).to receive(:respond_to?).with(:empty?).and_return(false)
            allow(child).to receive(:respond_to?).with(:generate_document).and_return(false)
          end
          it 'should not include the nested field (struct) in the extracted contents' do
            contents = subject.extract_contents_from(object, :index_name)
            expect(contents).not_to have_key 'a'
          end
        end
      end

      context 'when value is nil' do
        before { allow(object).to receive(:a) }
        it 'should return nil' do
          contents = subject.extract_contents_from(object, :index_name)
          expect(contents).to have_key 'a'
          expect(contents['a']).to be_nil
        end
      end
    end
  end
end
