require "spec_helper"

describe AgnosticBackend::Elasticsearch::IndexField do

  let(:field_name) { "field_name" }
  let(:field_type) { AgnosticBackend::Indexable::FieldType.new(
    AgnosticBackend::Indexable::FieldType::STRING) }

  subject { AgnosticBackend::Elasticsearch::IndexField.new(field_name, field_type) }

  context 'Type mappings' do
    it 'should map all Indexable FieldTypes to Cloudsearch types' do
      generic_types = AgnosticBackend::Indexable::FieldType.all.reject{|tp| tp == :struct}
      generic_types.each do |gtp|
        expect(AgnosticBackend::Elasticsearch::IndexField::TYPE_MAPPINGS).to include gtp
      end
    end
  end

  describe '#initialize' do
    it { expect(subject.name).to eq field_name }
    it { expect(subject.type).to eq field_type }
  end

  describe '#analyzed?' do
    let(:index_field) { AgnosticBackend::Elasticsearch::IndexField.new('field_name', field_type) }
    context 'when field type is TEXT' do
      let(:field_type) { AgnosticBackend::Indexable::FieldType.new(AgnosticBackend::Indexable::FieldType::TEXT) }
      it 'should return true' do
        expect(index_field.analyzed?).to be true
      end
    end

    context 'when field type is TEXT_ARRAY' do
      let(:field_type) { AgnosticBackend::Indexable::FieldType.new(AgnosticBackend::Indexable::FieldType::TEXT_ARRAY) }
      it 'should return true' do
        expect(index_field.analyzed?).to be true
      end
    end

    context 'when field type is anything else' do
      let(:field_type) { AgnosticBackend::Indexable::FieldType.new(AgnosticBackend::Indexable::FieldType::STRING) }
      it 'should return false' do
        expect(index_field.analyzed?).to be false
      end
    end
  end

  describe '#analyzed_property' do
    context 'given an analyzed field' do
      before { expect(subject).to receive(:analyzed?).and_return true }
      it 'should return an empty hash' do
        expect(subject.analyzed_property).to eq({})
      end
    end

    context 'given an non-analyzed field' do
      before { expect(subject).to receive(:analyzed?).and_return false }
      it 'should return {\'index\' => \'not_analyzed\'}' do
        expect(subject.analyzed_property).to eq({'index' => 'not_analyzed'})
      end 
    end
  end
end
