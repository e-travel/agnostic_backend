require 'spec_helper'

describe AgnosticBackend::Indexable do

  describe 'Indexable functionality' do

    let(:field_block) { proc {
                          string :a;
                          string 'b', value: 'b';
                          string :c, value: proc { a_message }
                        } }

    before do
      Object.send(:remove_const, :IndexableObject) if Object.constants.include? :IndexableObject
      class IndexableObject; end
      IndexableObject.send(:include, AgnosticBackend::Indexable)
    end

    subject { IndexableObject.new }

    describe '.includers' do
      it { expect(AgnosticBackend::Indexable.includers).to include IndexableObject }

      context 'when the same class includes Indexable twice' do
        before { IndexableObject.send(:include, AgnosticBackend::Indexable) }
        it 'should appear once in the includers array' do
          expect(AgnosticBackend::Indexable.includers.count{|klass| klass == IndexableObject}).to eq 1
        end
      end
    end

    describe '.indexable_class' do
      context 'when an indexable class that corresponds to the index_name exists' do
        let(:index_name) { IndexableObject.index_name }
        it 'should return the indexable_class ' do
          expect(AgnosticBackend::Indexable.indexable_class(index_name).name).to eq IndexableObject.name
        end
      end

      context 'when an indexable class that corresponds to the index_name does not exist' do
        let(:index_name) { 'no_such_index_exists' }
        it { expect(AgnosticBackend::Indexable.indexable_class(index_name)).to be_nil }
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
          expect(AgnosticBackend::Indexable::Config).
              to receive(:create_index_for).
                     with(IndexableObject).
                     and_return index
          expect(IndexableObject.create_index).to eq index
        end
      end

      describe '.create_indices' do
        let(:index) { double('Index') }
        it 'should use the Config object to create an array of indices' do
          expect(AgnosticBackend::Indexable::Config).
              to receive(:create_indices_for).
                     with(IndexableObject).
                     and_return [index]
          expect(IndexableObject.create_indices).to eq [index]
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
              expect(managers.values.first).to be_a AgnosticBackend::Indexable::ContentManager
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
              expect(managers.values.all?{|v| v.is_a? AgnosticBackend::Indexable::ContentManager}).
                  to be true
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
              expect(notifiers.values.all?{|v| v.is_a? Proc}).to be true
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

      describe '#put_to_index' do
        let(:indexer) { AgnosticBackend::Indexer.new(index) }
        let(:index) { AgnosticBackend::Index.new(klass) }

        before do
          allow_any_instance_of(AgnosticBackend::Index).to receive(:parse_options)
          expect(index).to receive(:indexer).twice.and_return(indexer)
          expect(klass).to receive(:create_indices).and_return([index, index])
          expect(indexer).to receive(:put).twice.with(subject).and_return('Result')
        end

        context 'when the index_name is specified' do
          let(:klass) { double("AnotherIndexableObject") }
          it 'should index itself in all requested index' do
            expect(AgnosticBackend::Indexable).
              to receive(:indexable_class).
                  with("index_name").
                  and_return klass
            expect(subject.put_to_index('index_name')).to eq ['Result', 'Result']
          end
        end

        context 'when the index_name is nil' do
          let(:klass) { subject.class}
          it 'should index itself in the default index' do
            expect(subject.put_to_index).to eq ['Result', 'Result']
          end
        end
      end

      describe '#trigger_index_notification' do
        before { allow(IndexableObject).to receive(:after_commit) }
        context 'when the target has been defined' do
          before { IndexableObject.define_index_notifier { self } }
          it 'should notify the notifier' do
            expect(subject).to receive(:index_object).with('indexable_objects')
            subject.send(:trigger_index_notification)
          end
        end
        context 'when multiple targets have been defined' do
          let(:targets) { [double('Target1'), double('Target2')] }
          before do
            IndexableObject.define_index_notifier { targets }
            allow(subject).to receive(:targets).and_return(targets)
          end
          it 'should notify the notifier' do
            targets.each {|target| expect(target).to receive(:index_object).with('indexable_objects')}
            subject.send(:trigger_index_notification)
          end
        end
        context 'when a target has not been defined' do
          it 'should do nothing' do
            expect(subject).not_to respond_to :_index_root_notifiers
            expect(subject).to receive(:respond_to?).with(:_index_root_notifiers).and_call_original
            expect(subject.send(:trigger_index_notification)).to be_nil
          end
        end
      end

      describe '#index_object' do
        it "should default to calling put_to_index" do
          expect(subject).to receive(:put_to_index).with(:not_there)
          subject.index_object(:not_there)
        end
      end
    end
  end
end
