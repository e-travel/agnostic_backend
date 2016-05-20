require 'spec_helper'

describe AgnosticBackend::Cloudsearch::Index do

  let(:field_block) do
    proc {
      integer :id
      string :a_string
      string_array :a_string_array
      double :a_double
      boolean :a_boolean
      text :a_text
      text_array :a_text_array
    }
  end

  before do
    Object.send(:remove_const, :IndexableObject) if Object.constants.include? :IndexableObject
    class IndexableObject; end
    IndexableObject.send(:include, AgnosticBackend::Indexable)
    IndexableObject.define_index_fields &field_block

    if AgnosticBackend::Indexable::Config.indices[IndexableObject.name].nil?
      AgnosticBackend::Indexable::Config.configure_index(
        IndexableObject,
        AgnosticBackend::Cloudsearch::Index,
        access_key_id: 'the_access_key_id',
        secret_access_key: 'the_secret_access_key',
        region: 'the_region',
        domain_name: 'the_domain_name',
        document_endpoint: 'the_document_endpoint',
        search_endpoint: 'the_search_endpoint'
      )
    end
  end

  subject { IndexableObject.create_index }

  it { should be_a AgnosticBackend::Index }

  describe '#initialize' do
    it { expect(subject.access_key_id).to eq 'the_access_key_id' }
    it { expect(subject.secret_access_key).to eq 'the_secret_access_key' }
    it { expect(subject.region).to eq 'the_region' }
    it { expect(subject.domain_name).to eq 'the_domain_name' }
    it { expect(subject.document_endpoint).to eq 'the_document_endpoint' }
    it { expect(subject.search_endpoint).to eq 'the_search_endpoint' }
  end

  describe '#indexer' do
    it { expect(subject.indexer).to be_a AgnosticBackend::Cloudsearch::Indexer }
  end

  describe '#query_builder' do
    it { expect(subject.query_builder).to be_a AgnosticBackend::Queryable::QueryBuilder }
  end

  describe '#schema' do
    it 'should request the schema from the indexable_class' do
      expect(IndexableObject).to receive(:schema).and_call_original
      schema = subject.schema
      expect(schema.reject{|_,ftype| ftype.nested?}.
              all?{|_,ftype| ftype.is_a? AgnosticBackend::Indexable::FieldType}).to be true
    end
  end

  describe '#configure' do
    let(:flat_schema) { subject.indexer.flatten(IndexableObject.schema{|ftype| ftype}) }
    it 'should use the flat_schema in order to define the fields' do
      expect(subject).to receive(:define_fields_in_domain).with(flat_schema)
      subject.configure
    end
  end

  describe '#cloudsearch_client' do
    it 'should construct and return a new CloudSearch::Client' do
      expect(Aws::CloudSearch::Client).to receive(:new).with(region: 'the_region',
                                                             access_key_id: 'the_access_key_id',
                                                             secret_access_key: 'the_secret_access_key')
      subject.cloudsearch_client
    end
  end

  describe '#cloudsearch_domain_client' do
    it 'should construct and return a new CloudSearchDomain::Client for the specified endpoint' do
      expect(Aws::CloudSearchDomain::Client).to receive(:new).with(endpoint: 'the_search_endpoint',
                                                                   access_key_id: 'the_access_key_id',
                                                                   secret_access_key: 'the_secret_access_key')
      subject.cloudsearch_domain_client
    end
  end

  describe '#remove_fields_from_domain' do
    let(:client) { double("CloudsearchClient") }
    let(:remote_struct) { double("Struct") }
    let(:options) { double("Options", index_field_name: 'hello') }
    let(:remote_field) { AgnosticBackend::Cloudsearch::RemoteIndexField.new remote_struct }
    before do
      allow(subject).to receive(:cloudsearch_client).and_return(client)
      allow(remote_struct).to receive(:options).and_return(options)
      allow(remote_struct).to receive(:status)
    end

    it 'should remove all remote fields from the domain' do
      expect(client).to receive(:delete_index_field).with({domain_name: subject.domain_name,
                                                           index_field_name: options.index_field_name})
      subject.send(:remove_fields_from_domain, [remote_field], verbose: false)
    end
  end

  describe "#define_fields_in_domain" do

    let(:flat_schema) { subject.indexer.flatten(IndexableObject.schema{|ftype| ftype}) }
    let(:client) { double("CloudsearchClient") }
    before do
      allow(subject).to receive(:cloudsearch_client).and_return(client)
      allow(client).to receive(:describe_index_fields).and_return client_response
    end

    context 'when there exist obsolete remote fields' do
      let(:obsolete_remote_struct) { OpenStruct.new(options: OpenStruct.new(
                                                     index_field_name: "no_such_field_exists")) }
      let(:client_response) { double("Response", index_fields: [obsolete_remote_struct]) }
      before { allow(subject).to receive(:index_fields).and_return [] }
      it 'should remove them from the remote index' do
        expect(subject).to receive(:remove_fields_from_domain) do |arg|
          expect(arg.size).to eq 1
          remote_field = arg.first
          expect(remote_field.index_field_name).to eq 'no_such_field_exists'
        end
        subject.send(:define_fields_in_domain, flat_schema, verbose: false)
      end
    end

    context 'when a local field differs from the corresponding remote field' do
      let(:client_response) { double("Response", index_fields: [remote_struct]) }
      let(:remote_struct) { OpenStruct.new(options: OpenStruct.new(index_field_name: "id",
                                                                   index_field_type: "literal")) }
      before { flat_schema.select!{|key, ftype| key == 'id'} }
      it 'should configure the new field' do
        expect_any_instance_of(AgnosticBackend::Cloudsearch::IndexField).
          to receive(:equal_to_remote_field?).
              with(an_instance_of(AgnosticBackend::Cloudsearch::RemoteIndexField)).
              and_return(false)
        expect(subject).not_to receive(:remove_fields_from_domain)
        expect_any_instance_of(AgnosticBackend::Cloudsearch::IndexField).
          to receive(:define_in_domain).
              with(index: subject)
        subject.send(:define_fields_in_domain, flat_schema, verbose: false)
      end
    end

    context 'when a local field does not differ from the corresponding remote field' do
      let(:client_response) { double("Response", index_fields: [valid_remote_struct]) }
      before { flat_schema.select!{|key, ftype| key == 'id'} }
      let(:valid_remote_struct) { OpenStruct.new(options: OpenStruct.new(index_field_name: "id")) }
      it 'should do nothing' do
        expect_any_instance_of(AgnosticBackend::Cloudsearch::IndexField).
          to receive(:equal_to_remote_field?).
              with(an_instance_of(AgnosticBackend::Cloudsearch::RemoteIndexField)).
              and_return(true)
        expect(subject).not_to receive(:remove_fields_from_domain)
        expect_any_instance_of(AgnosticBackend::Cloudsearch::IndexField).
          not_to receive :define_in_domain
        subject.send(:define_fields_in_domain, flat_schema, verbose: false)
      end
    end

  end

  describe '#index_fields' do
    let(:schema) { {"alpha" => :integer, "beta" => :string} }
    it 'should create an IndexField for each entry of the flat schema' do
      fields = subject.send(:index_fields, schema)
      expect(fields.all?{|field| field.is_a? AgnosticBackend::Cloudsearch::IndexField}).to be true
      expect(fields.first.name).to eq 'alpha'
      expect(fields.first.type).to eq :integer
      expect(fields.last.name).to eq 'beta'
      expect(fields.last.type).to eq :string
    end
  end

  describe '#parse_option' do
    let(:options) { { a: 1 } }
    context 'when option_name is included in options as a key' do
      it 'should return its value' do
        expect(subject.send(:parse_option, options, :a)).to eq 1
      end
    end
    context 'when option_name is not included in options as a key' do
      it 'should raise an Exception' do
        expect{subject.send(:parse_option, options, :b)}.to raise_error "b must be specified"
      end
    end
    context 'when option is optional and does not exist in options' do
      it 'should return the default value' do
        expect(subject.send(:parse_option, options, :b, optional: true, default: 2)).to eq 2
      end
    end
  end

end
