require "spec_helper"

describe AgnosticBackend::Cloudsearch::IndexField do

  let(:field_name) { "field_name" }
  let(:field_type) { AgnosticBackend::Indexable::FieldType.new(
    AgnosticBackend::Indexable::FieldType::STRING) }

  subject { AgnosticBackend::Cloudsearch::IndexField.new(field_name, field_type) }

  context 'Type mappings' do
    it 'should map all Indexable FieldTypes to Cloudsearch types' do
      generic_types = AgnosticBackend::Indexable::FieldType.all.reject{|tp| tp == :struct}
      generic_types.each do |gtp|
        expect(AgnosticBackend::Cloudsearch::IndexField::TYPE_MAPPINGS).to include gtp
      end
    end
  end

  describe '#initialize' do
    it { expect(subject.name).to eq field_name }
    it { expect(subject.type).to eq field_type }
  end

  describe "#define_in_domain" do

    let(:client) { double("Client") }
    let(:index) { double("Index") }
    let(:index_name) { "index_name" }
    let(:definition) { double("IndexDefinition") }

    before do
      allow(index).to receive(:cloudsearch_client).and_return(client)
      allow(index).to receive(:domain_name).and_return index_name
    end

    it 'should use the client to define the field' do
      expect(subject).to receive(:definition).and_return(definition)
      expect(client).to receive(:define_index_field).with(domain_name: index_name,
                                                          index_field: definition)
      subject.define_in_domain(index: index)
    end

  end

  describe '#equal_to_remote_field?' do
    let(:remote_field) { AgnosticBackend::Cloudsearch::RemoteIndexField.new remote_struct }

    context 'when names are different' do
      let(:remote_struct) do
        OpenStruct.new(options:OpenStruct.new(index_field_name: "different_name",
                                              index_field_type: subject.send(:cloudsearch_type),
                                              literal_options: OpenStruct.new))
      end
      before { allow(subject).to receive(:options).and_return({}) }
      it { expect(subject.equal_to_remote_field?(remote_field)).to be false }
    end

    context 'when types are different' do
      let(:remote_struct) do
        OpenStruct.new(options:OpenStruct.new(index_field_name: field_name,
                                              index_field_type: "_#{subject.send(:cloudsearch_type)}",
                                              literal_options: OpenStruct.new))
      end
      before { allow(subject).to receive(:options).and_return({}) }
      it { expect(subject.equal_to_remote_field?(remote_field)).to be false }
    end

    context 'when at least one option is different' do
      let(:remote_struct) do
        OpenStruct.new(options:OpenStruct.new(index_field_name: field_name,
                                              index_field_type: subject.send(:cloudsearch_type),
                                              literal_options: OpenStruct.new(a: 1)))
      end
      it { expect(subject.equal_to_remote_field?(remote_field)).to be false }
    end

    context 'when everything is the same' do
      let(:options) { {a: 1, b: 2} }
      let(:remote_struct) do
        OpenStruct.new(options:OpenStruct.new(index_field_name: field_name,
                                              index_field_type: subject.send(:cloudsearch_type),
                                              literal_options: OpenStruct.new(**options)))
      end
      before { allow(subject).to receive(:options).and_return(options) }
      it { expect(subject.equal_to_remote_field?(remote_field)).to be true }
    end

  end

  describe '#sortable?' do
    let(:index_field) { AgnosticBackend::Cloudsearch::IndexField.new 'field_name', field_type }

    context 'when sortable param has not been set on the field type' do
      let(:field_type) { AgnosticBackend::Indexable::FieldType.new(
        AgnosticBackend::Indexable::FieldType::INTEGER) }
      it 'should return true by default' do
        expect(index_field).to be_sortable
      end
    end

    context 'when sortable param has been set on the field type' do
      let(:field_type) { AgnosticBackend::Indexable::FieldType.new(
        AgnosticBackend::Indexable::FieldType::INTEGER,
        sortable: false) }
      it 'should return the value that was set' do
        expect(index_field).not_to be_sortable
      end
    end
  end

  describe '#searchable?' do
    let(:index_field) { AgnosticBackend::Cloudsearch::IndexField.new 'field_name', field_type }

    context 'when searchable param has not been set on the field type' do
      let(:field_type) { AgnosticBackend::Indexable::FieldType.new(
        AgnosticBackend::Indexable::FieldType::INTEGER) }
      it 'should return true by default' do
        expect(index_field).to be_searchable
      end
    end

    context 'when searchable param has been set on the field type' do
      let(:field_type) { AgnosticBackend::Indexable::FieldType.new(
        AgnosticBackend::Indexable::FieldType::INTEGER,
        searchable: false) }
      it 'should return the value that was set' do
        expect(index_field).not_to be_searchable
      end
    end
  end

  describe '#returnable?' do
    let(:index_field) { AgnosticBackend::Cloudsearch::IndexField.new 'field_name', field_type }

    context 'when returnable param has not been set on the field type' do
      let(:field_type) { AgnosticBackend::Indexable::FieldType.new(
        AgnosticBackend::Indexable::FieldType::INTEGER) }
      it 'should return true by default' do
        expect(index_field).to be_returnable
      end
    end

    context 'when returnable param has been set on the field type' do
      let(:field_type) { AgnosticBackend::Indexable::FieldType.new(
        AgnosticBackend::Indexable::FieldType::INTEGER,
        returnable: false) }
      it 'should return the value that was set' do
        expect(index_field).not_to be_returnable
      end
    end
  end

  describe '#facetable?' do
    let(:index_field) { AgnosticBackend::Cloudsearch::IndexField.new 'field_name', field_type }

    context 'when facetable param has not been set on the field type' do
      let(:field_type) { AgnosticBackend::Indexable::FieldType.new(
        AgnosticBackend::Indexable::FieldType::INTEGER) }
      it 'should return false by default' do
        expect(index_field).not_to be_facetable
      end
    end

    context 'when facetable param has been set on the field type' do
      let(:field_type) { AgnosticBackend::Indexable::FieldType.new(
        AgnosticBackend::Indexable::FieldType::INTEGER,
        facetable: true) }
      it 'should return the value that was set' do
        expect(index_field).to be_facetable
      end
    end
  end

  describe "#definition" do
    let(:cloudsearch_type) { subject.send(:cloudsearch_type) }
    it "should return a hash representing the subject in cloudsearch" do
      result = subject.send(:definition)
      expect(result[:index_field_name]).to eq subject.name.to_s
      expect(result[:index_field_type]).to eq cloudsearch_type
      field_options = result["#{cloudsearch_type}_options".to_sym]
      expect(field_options[:sort_enabled]).to eq subject.sortable?
      expect(field_options[:search_enabled]).to eq subject.searchable?
      expect(field_options[:return_enabled]).to eq subject.returnable?
      expect(field_options[:facet_enabled]).to eq subject.facetable?
    end
  end

  describe '#options' do
    let(:options) { subject.send(:options) }
    context 'when cloudsearch type is text-array' do
      before { allow(subject).to receive(:cloudsearch_type).and_return 'text-array' }
      it 'should include the appropriate options' do
        expect(options).to include :return_enabled
        expect(options.size).to eq 1
      end
    end
    context 'when cloudsearch type is text' do
      before { allow(subject).to receive(:cloudsearch_type).and_return 'text' }
      it 'should include the appropriate options' do
        expect(options).to include :return_enabled
        expect(options).to include :sort_enabled
        expect(options.size).to eq 2
      end
    end
    context 'when cloudsearch type is literal-array' do
      before { allow(subject).to receive(:cloudsearch_type).and_return 'literal-array' }
      it 'should include the appropriate options' do
        expect(options).to include :return_enabled
        expect(options).to include :search_enabled
        expect(options).to include :facet_enabled
        expect(options.size).to eq 3
      end
    end
    context 'when cloudsearch type is date-array' do
      before { allow(subject).to receive(:cloudsearch_type).and_return 'literal-array' }
      it 'should include the appropriate options' do
        expect(options).to include :return_enabled
        expect(options).to include :search_enabled
        expect(options).to include :facet_enabled
        expect(options.size).to eq 3
      end
    end
    context 'when cloudsearch type is anything else' do
      before { allow(subject).to receive(:cloudsearch_type).and_return 'int' }
      it 'should include the appropriate options' do
        expect(options).to include :return_enabled
        expect(options).to include :search_enabled
        expect(options).to include :facet_enabled
        expect(options).to include :sort_enabled
        expect(options.size).to eq 4
      end
    end
  end
end
