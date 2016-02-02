require 'spec_helper'

describe AgnosticStore::Indexable do
  describe AgnosticStore::Indexable::Config do
    subject { AgnosticStore::Indexable::Config }

    let(:index_class) { double('IndexClass') }
    let(:indexable_class) { double('IndexableClass', name:'IndexableClass') }
    let(:options) { {a: 'A'} }

    describe '.configure_index' do
      it 'should configure the index' do
        subject.configure_index(indexable_class, index_class, **options)
        entry = subject.indices[indexable_class.name]
        expect(entry.index_class).to eq index_class
        expect(entry.options).to eq options
      end
    end

    describe '.create_index_for' do
      before { subject.configure_index(indexable_class, index_class)}
      it 'should create a new Index' do
        expect(index_class).to receive(:new).with(indexable_class, {})
        subject.create_index_for(indexable_class)
      end
    end
  end

  describe AgnosticStore::Indexable::FieldType do
    subject { AgnosticStore::Indexable::FieldType }

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

  describe AgnosticStore::Indexable::Field do
    subject { AgnosticStore::Indexable::Field }

    describe '#initialize' do
      context 'when type is not supported ' do
        it 'should raise an exception' do
          expect { subject.new 'hello', :invalid_type }.to raise_error /not supported/
        end
      end

      context 'when type is supported' do
        it 'should create and store a FieldType' do
          field = subject.new 'hello', AgnosticStore::Indexable::FieldType::INTEGER
          expect(field.type).to be_a AgnosticStore::Indexable::FieldType
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

  describe AgnosticStore::Indexable::ContentManager do
    subject { AgnosticStore::Indexable::ContentManager.new }

    describe '#add_definitions' do
      let(:field_block) { Proc.new { field :a } }
      it 'should execute the supplied block' do
        expect(subject).to receive(:field).with(:a)
        subject.add_definitions &field_block
      end
    end

    describe '#method_missing' do
      context 'when the method name is a field type' do
        before { allow(AgnosticStore::Indexable::FieldType).to receive(:exists?).and_return true }
        it 'should add the field to the contents' do
          expect(subject).to receive(:field).with(:field_name, {value: nil, type: :foo}).
                                 and_call_original
          subject.send(:foo, :field_name, value: nil, type: :foo)
        end
      end

      context 'when the method name is not a field type' do
        before { allow(AgnosticStore::Indexable::FieldType).to receive(:exists?).and_return false }
        it 'should forward the message to its superclass' do
          expect { subject.send(:foo, :arg1, kwarg1: :hello) }.to raise_error NoMethodError
        end
      end
    end

    describe '#respond_to?' do
      context 'when sym is a Field type' do
        it { expect(AgnosticStore::Indexable::FieldType.all.all?{|type| subject.respond_to? type })
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
          expect(AgnosticStore::Indexable::Field).
              to receive(:new).with(:a, :integer, {:from=>nil}).
                     and_call_original
          subject.field(:a, type: :integer)
          expect(subject.contents['a']).to be_a AgnosticStore::Indexable::Field
        end
      end

      context 'when value: is present' do
        it 'should add a Field with the value into the hash' do
          expect(AgnosticStore::Indexable::Field).
              to receive(:new).with(:b, :text, {:from=>nil}).
                     and_call_original
          subject.field(:a, value: :b, type: :text)
          expect(subject.contents['a']).to be_a AgnosticStore::Indexable::Field
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

  describe 'Indexable functionality' do

    let(:field_block) { proc { string :a; string 'b', value: 'b'; string :c, value: proc { a_message } } }

    before do
      Object.send(:remove_const, :IndexableObject) if Object.constants.include? :IndexableObject
      class IndexableObject; end
      allow(IndexableObject).to receive(:<).with(ActiveRecord::Base).and_return true
      IndexableObject.send(:include, AgnosticStore::Indexable)
    end

    subject { IndexableObject.new }

    describe '.includers' do
      it { expect(AgnosticStore::Indexable.includers).to include IndexableObject }

      context 'when the same class includes Indexable twice' do
        before { IndexableObject.send(:include, AgnosticStore::Indexable) }
        it 'should appear once in the includers array' do
          expect(AgnosticStore::Indexable.includers.count{|klass| klass == IndexableObject}).to eq 1
        end
      end
    end

    describe '.indexable_class' do
      context 'when an indexable class that corresponds to the index_name exists' do
        let(:index_name) { IndexableObject.index_name }
        it 'should return the indexable_class ' do
          expect(AgnosticStore::Indexable.indexable_class(index_name).name).to eq IndexableObject.name
        end
      end

      context 'when an indexable class that corresponds to the index_name does not exist' do
        let(:index_name) { 'no_such_index_exists' }
        it { expect(AgnosticStore::Indexable.indexable_class(index_name)).to be_nil }
      end
    end

    it { expect(IndexableObject).to respond_to :index_name }
    it { expect(IndexableObject).to respond_to :index_content_manager }
    it { expect(IndexableObject).to respond_to :schema }
    it { expect(IndexableObject).to respond_to :define_index_fields }
    it { expect(IndexableObject).to respond_to :define_index_notifier }

    it { expect(subject).to respond_to :index_name }
    it { expect(subject).to respond_to :generate_document }

    describe 'ClassMethods' do
      describe '.create_index' do
        let(:index) { double('Index') }
        it 'should use the Config object to create an index' do
          expect(AgnosticStore::Indexable::Config).
              to receive(:create_index_for).
                     with(IndexableObject).
                     and_return index
          expect(IndexableObject.create_index).to eq index
        end
      end

      describe '.index_name' do
        context 'when source is nil' do
          it 'should transform self\'s name' do
            expect(IndexableObject.index_name).to eq 'indexable_objects'
          end
        end
        context 'when source is present' do
          it 'should transform the source' do
            expect(IndexableObject.index_name('N::TheQueue')).to eq 'the_queues'
          end
        end
      end

      describe '._index_content_managers' do
        it { expect(IndexableObject._index_content_managers).to be_empty }
        context 'when contents are added to the Hash' do
          before { IndexableObject._index_content_managers[:a] = 'hello' }
          it 'should store and return them' do
            expect(IndexableObject._index_content_managers.size).to eq 1
            expect(IndexableObject._index_content_managers.first).to eq [:a, 'hello']
          end
        end
      end

      describe '.index_content_manager' do
        context 'when the manager exists for the specified index name' do
          before { IndexableObject._index_content_managers['a'] = 'hello' }
          it { expect(IndexableObject.index_content_manager(:a)).to eq 'hello' }
        end

        context 'when the manager does not exist for the specified index name' do
          it { expect(IndexableObject.index_content_manager('a')).to be_nil }
        end
      end

      describe '._index_root_notifiers' do
        it { expect(IndexableObject._index_root_notifiers).to be_empty }

        context 'when notifiers are added to the Hash' do
          before { IndexableObject._index_root_notifiers[:a] = 'hello' }
          it 'should store and return them' do
            expect(IndexableObject._index_root_notifiers.size).to eq 1
            expect(IndexableObject._index_root_notifiers.first).to eq [:a, 'hello']
          end
        end
      end

      describe '.index_root_notifier' do
        context 'when the notifier exists for the specified index name' do
          before { IndexableObject._index_root_notifiers['a'] = 'hello' }
          it { expect(IndexableObject.index_root_notifier(:a)).to eq 'hello' }
        end

        context 'when the notifier does not exist for the specified index name' do
          it { expect(IndexableObject.index_root_notifier('a')).to be_nil }
        end
      end

      describe '.schema' do

        context 'when for_index: is nil' do
          it 'should query the class for its default index_name' do
            expect(IndexableObject).to receive(:index_name).and_call_original
            IndexableObject.schema rescue nil
          end
        end

        context 'when the index_name does not exist' do
          it { expect{IndexableObject.schema(for_index: :aaaa)}.to raise_error /has not been defined/ }
        end

        context 'when the field is not nested' do
          let(:block) { proc { string :a } }
          before { IndexableObject.define_index_fields &block }
          it 'should return a hash with the field\'s type' do
            schema = IndexableObject.schema(for_index: :indexable_objects)
            expect(schema['a']).to eq :string
          end
        end

        context 'when the field is nested' do
          let(:block) { proc { struct :a, from: [Klass1, Klass2] } }
          before do
            class Klass1; end
            class Klass2; end
            IndexableObject.define_index_fields &block
          end

          it 'should merge the hashes retrieved from the field\'s `from` classes' do
            expect(Klass1).to receive(:schema).with(for_index: :indexable_objects).and_return({'b' => 1})
            expect(Klass2).to receive(:schema).with(for_index: :indexable_objects).and_return({'c' => 2})
            schema = IndexableObject.schema(for_index: :indexable_objects)
            expect(schema['a']).to eq({'b' => 1, 'c' => 2})
          end
        end

        context 'when a block is given' do
          let(:block) { proc { string :a, sortable: false } }
          before { IndexableObject.define_index_fields &block }
          it 'should return as values the result of the block' do
            expect(IndexableObject.schema{|ftype| ftype.get_option('sortable')}).to eq({'a' => false})
          end
        end
      end

      describe '.define_index_fields_for' do
        context 'when no block is supplied' do
          it 'should do nothing' do
            expect(IndexableObject).not_to receive(:define_method)
            IndexableObject.define_index_fields
            expect(subject).not_to respond_to :_index_content_managers
          end
        end

        context 'when a block is supplied' do
          before do
            expect(subject).not_to respond_to :_index_content_managers
            expect(IndexableObject).to receive(:define_method).and_call_original
            IndexableObject.define_index_fields &field_block
          end

          it { expect(subject).to respond_to :_index_content_managers }

          describe '#_index_content_managers' do
            it 'should return a Hash with the content managers (coming from its class)' do
              managers = subject.send(:_index_content_managers)
              expect(managers).to eq subject.class._index_content_managers
              expect(managers.keys).to eq ['indexable_objects']
              expect(managers.values.first).to be_a AgnosticStore::Indexable::ContentManager
            end
            it 'should setup the correct context for assembling the values' do
              managers = subject.send(:_index_content_managers)
              expect(subject).to receive(:a)
              expect(subject).to receive(:b)
              expect(subject).to receive(:a_message)
              expect { managers['indexable_objects'].extract_contents_from(subject, :index_name) }.
                  to_not raise_error
            end
            it 'should be able to add an additional index manager to the hash' do
              IndexableObject.define_index_fields(owner: 'test', &field_block)
              managers = subject.send(:_index_content_managers)
              expect(managers.keys).to eq ['indexable_objects', 'tests']
              expect(managers.values.all?{|v| v.is_a? AgnosticStore::Indexable::ContentManager}).
                  to be_true
            end
          end
        end
      end

      describe '.define_index_notifier' do
        context 'when no block is supplied' do
          it 'should do nothing' do
            expect(IndexableObject).not_to receive(:define_method)
            expect(IndexableObject).not_to receive(:after_commit)
            # trigger method
            IndexableObject.define_index_notifier
          end
        end
        context 'when a block is supplied' do
          let(:root) { double('RootObject') }
          before do
            expect(subject).not_to respond_to :_index_root_notifiers
            expect(IndexableObject).to receive(:define_method).and_call_original
            expect(IndexableObject).to receive(:after_commit)
            # trigger method
            IndexableObject.define_index_notifier { root }
          end

          it { expect(subject).to respond_to :_index_root_notifiers }

          context 'when an manager has not previously defined for a given index name' do
            it 'should return nil when requesting a document' do
              expect(subject.generate_document(for_index: 'whatever')).to be_nil
            end
          end

          describe '#_index_root_notifiers' do
            it 'should return a Hash with the root notifiers' do
              notifiers = subject.send(:_index_root_notifiers)
              expect(notifiers).to eq subject.class._index_root_notifiers
              expect(notifiers.keys).to eq ['indexable_objects']
              expect(notifiers.values.first).to be_a Proc
              expect(notifiers.values.first.call).to eq root
            end
            it 'should be able to add an additional root notifier to the hash' do
              IndexableObject.define_index_notifier(target: 'test', &field_block)
              notifiers = subject.send(:_index_root_notifiers)
              expect(notifiers.keys).to eq ['indexable_objects', 'tests']
              expect(notifiers.values.all?{|v| v.is_a? Proc}).to be_true
            end
          end
        end
      end
    end

    describe 'InstanceMethods' do
      describe '#index_name' do
        it 'should forward the message to its class' do
          expect(subject.class).to receive(:index_name).with('hello')
          subject.index_name('hello')
        end
      end

      describe '#generate_document' do
        context 'when for_index: is not specified' do
          it 'should query the object for its default index_name' do
            expect(subject).to receive(:index_name).and_call_original
            subject.generate_document
          end
        end

        context 'when the fields to be indexed have not been specified' do
          before { expect(subject).to_not respond_to :_index_content_managers }
          it { expect(subject.generate_document(for_index: :whatever)).to be_nil }
        end

        context 'when the index_name does not exist' do
          before { IndexableObject.define_index_fields &field_block }
          it { expect { subject.generate_document(for_index: 'test2')}.to raise_error /does not exist/ }
        end

        context 'when the fields to be indexed have been specified' do
          before do
            IndexableObject.define_index_fields &field_block
            allow(subject).to receive(:a).and_return('Hello')
            allow(subject).to receive(:b).and_return('Goodbye')
            allow(subject).to receive(:a_message).and_return('A Message')
          end
          it 'should return a document representation of the object' do
            expect(subject.generate_document(for_index: 'indexable_objects')).
                to eq({'a' => 'Hello', 'b' => 'Goodbye', 'c' => 'A Message'})
          end
        end
      end

      describe '#put_in_index' do
        let(:index) { AgnosticStore::Index.new(subject) }
        let(:indexer) { AgnosticStore::Indexer.new(index) }
        before { allow(IndexableObject).to receive(:create_index).and_return(index) }
        it 'should index itself' do
          expect(index).to receive(:indexer).and_return(indexer)
          expect(indexer).to receive(:put).with(subject).and_return('Result')
          expect(subject.put_in_index).to eq 'Result'
        end
      end

      describe '#trigger_index_notification_on_save' do
        before { allow(IndexableObject).to receive(:after_commit) }
        context 'when the target has been defined' do
          before { IndexableObject.define_index_notifier { self } }
          it 'should notify the notifier' do
            expect(subject).to receive(:enqueue_for_indexing).with('indexable_objects')
            subject.send(:trigger_index_notification_on_save)
          end
        end
        context 'when multiple targets have been defined' do
          let(:targets) { [double('Target1'), double('Target2')] }
          before do
            IndexableObject.define_index_notifier { targets }
            allow(subject).to receive(:targets).and_return(targets)
          end
          it 'should notify the notifier' do
            targets.each {|target| expect(target).to receive(:enqueue_for_indexing).with('indexable_objects')}
            subject.send(:trigger_index_notification_on_save)
          end
        end
        context 'when a target has not been defined' do
          it 'should do nothing' do
            expect(subject).not_to respond_to :_index_root_notifiers
            expect(subject).to receive(:respond_to?).with(:_index_root_notifiers).and_call_original
            expect(subject.send(:trigger_index_notification_on_save)).to be_nil
          end
        end
      end

      describe '#enqueue_for_indexing' do
        context 'when index_name has not been defined' do
          before { allow(subject).to receive(:_index_content_managers).and_return({}) }
          it 'should do nothing' do
            expect(AgnosticStore::DocumentBufferItem).not_to receive(:create)
            subject.enqueue_for_indexing :not_there
          end
        end

        context 'when index_name is defined' do
          let(:managers) { {'indexable_objects' => :manager} }
          before do
            allow(subject).to receive(:_index_content_managers).and_return managers
            allow(subject).to receive(:id).and_return 111
          end
          it 'should create a DocumentBufferItem and schedule the indexing' do
            expect(AgnosticStore::DocumentBufferItem).
                to receive(:create!).with(model_id: subject.id,
                                          model_type: 'IndexableObject',
                                          index_name: 'indexable_objects').
                       and_call_original
            expect_any_instance_of(AgnosticStore::DocumentBufferItem).to receive(:schedule_indexing)
            subject.enqueue_for_indexing :indexable_objects
          end
        end
      end
    end
  end
end
