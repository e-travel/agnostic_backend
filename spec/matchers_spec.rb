require 'spec_helper'

describe 'Indexable matchers' do

  before do
    Object.send(:remove_const, :IndexableObject) if Object.constants.include? :IndexableObject
    class IndexableObject; end
    IndexableObject.send(:include, AgnosticBackend::Indexable)
  end

  describe 'be_indexable' do
    context 'when the class includes Indexable' do
      it { expect(IndexableObject).to be_indexable }
    end
    context 'when the class does not include Indexable' do
      it { expect(Object).not_to be_indexable }
    end
  end

  describe 'define_index_field' do
    let(:field_block) { proc { integer :a, value: 'A', attr1: 'A', attr2: 'B'} }
    before { IndexableObject.define_index_fields &field_block }

    it { expect(IndexableObject).to define_index_field(:a) }
    it { expect(IndexableObject).to define_index_field(:a, type: :integer) }
    it { expect(IndexableObject).to define_index_field(:a, type: :integer, attr1: 'A', attr2: 'B') }

    it { expect(IndexableObject).not_to define_index_field(:b) }
    it { expect(IndexableObject).not_to define_index_field(:a, attr3: 'C') }
    it { expect(IndexableObject).not_to define_index_field(:a, type: :string) }
  end

end
