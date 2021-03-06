require 'spec_helper'

describe AgnosticBackend::Queryable::CriteriaBuilder do
  let(:schema) do
    {
        'an_integer' => double('FieldType', type: :integer),
        'a_string' => double('FieldType', type: :string),
        'a_date' => double('FieldType', type: :date)
    }
  end
  let(:index) { double('Index', schema: schema) }
  let(:context) { double('Context', index: index) }

  describe 'initialize' do
    it 'should create context instance variable' do
      builder = AgnosticBackend::Queryable::CriteriaBuilder.new(context)
      expect(builder.context).to eq context
    end
  end

  let(:subject) { AgnosticBackend::Queryable::CriteriaBuilder.new(context) }
  describe '#not' do
    it 'should initialize a Not operation' do
      expect(AgnosticBackend::Queryable::Operations::Not).to receive(:new).with(operand: 'foo', context: context).and_call_original
      expect(subject.not('foo')).to be_a(AgnosticBackend::Queryable::Operations::Not)
    end
  end

  describe '#and' do
    it 'should initialize an And operation' do
      expect(AgnosticBackend::Queryable::Operations::And).to receive(:new).with(operands: ['foo', 'bar'], context: context).and_call_original
      expect(subject.and('foo', 'bar')).to be_a(AgnosticBackend::Queryable::Operations::And)
    end
  end

  describe '#all' do
    it 'should initialize an And operation' do
      expect(AgnosticBackend::Queryable::Operations::And).to receive(:new).with(operands: ['foo', 'bar'], context: context).and_call_original
      expect(subject.all('foo', 'bar')).to be_a(AgnosticBackend::Queryable::Operations::And)
    end
  end

  describe '#or' do
    it 'should initialize an Or operation' do
      expect(AgnosticBackend::Queryable::Operations::Or).to receive(:new).with(operands: ['foo', 'bar'], context: context).and_call_original
      expect(subject.or('foo', 'bar')).to be_a(AgnosticBackend::Queryable::Operations::Or)
    end
  end

  describe '#any' do
    it 'should initialize an Or operation' do
      expect(AgnosticBackend::Queryable::Operations::Or).to receive(:new).with(operands: ['foo', 'bar'], context: context).and_call_original
      expect(subject.any('foo', 'bar')).to be_a(AgnosticBackend::Queryable::Operations::Or)
    end
  end

  describe '#eq' do
    it 'should initialize an Equal criterion' do
      expect(AgnosticBackend::Queryable::Criteria::Equal).to receive(:new).with(attribute: 'an_integer', value: 1, context: context).and_call_original
      expect(subject.eq('an_integer', 1)).to be_a(AgnosticBackend::Queryable::Criteria::Equal)
    end
  end

  describe '#free_text' do
    it 'should initialize an FreeText criterion' do
      expect(AgnosticBackend::Queryable::Criteria::FreeText).to receive(:new).with(attribute: '*', value: 'abcde', context: context).and_call_original
      expect(subject.free_text('*', 'abcde')).to be_a(AgnosticBackend::Queryable::Criteria::FreeText)
    end
  end

  describe '#fuzzy' do
    it 'should initialize an Fuzzy criterion' do
      expect(AgnosticBackend::Queryable::Criteria::Fuzzy).to receive(:new).with(attribute: '*', value: 'abcde', context: context, fuzziness: 2).and_call_original
      expect(subject.fuzzy('*', 'abcde', 2)).to be_a(AgnosticBackend::Queryable::Criteria::Fuzzy)
    end
  end

  describe '#neq' do
    it 'should initialize a NotEqual criterion' do
      expect(AgnosticBackend::Queryable::Criteria::NotEqual).to receive(:new).with(attribute: 'an_integer', value: 1, context: context).and_call_original
      expect(subject.neq('an_integer', 1)).to be_a(AgnosticBackend::Queryable::Criteria::NotEqual)
    end
  end

  describe '#gt' do
    it 'should initialize a Greater criterion' do
      expect(AgnosticBackend::Queryable::Criteria::Greater).to receive(:new).with(attribute: 'an_integer', value: 1, context: context).and_call_original
      expect(subject.gt('an_integer', 1)).to be_a(AgnosticBackend::Queryable::Criteria::Greater)
    end
  end

  describe '#lt' do
    it 'should initialize a Less criterion' do
      expect(AgnosticBackend::Queryable::Criteria::Less).to receive(:new).with(attribute: 'an_integer', value: 1, context: context).and_call_original
      expect(subject.lt('an_integer', 1)).to be_a(AgnosticBackend::Queryable::Criteria::Less)
    end
  end

  describe '#ge' do
    it 'should initialize a GreaterEqual criterion' do
      expect(AgnosticBackend::Queryable::Criteria::GreaterEqual).to receive(:new).with(attribute: 'an_integer', value: 1, context: context).and_call_original
      expect(subject.ge('an_integer', 1)).to be_a(AgnosticBackend::Queryable::Criteria::GreaterEqual)
    end
  end

  describe '#le' do
    it 'should initialize a LessEqual criterion' do
      expect(AgnosticBackend::Queryable::Criteria::LessEqual).to receive(:new).with(attribute: 'an_integer', value: 1, context: context).and_call_original
      expect(subject.le('an_integer', 1)).to be_a(AgnosticBackend::Queryable::Criteria::LessEqual)
    end
  end

  describe '#gt_and_lt' do
    it 'should initialize a GreaterAndLess criterion' do
      expect(AgnosticBackend::Queryable::Criteria::GreaterAndLess).to receive(:new).with(attribute: 'an_integer', left_value: 5, right_value: 10, context: context).and_call_original
      expect(subject.gt_and_lt('an_integer', 5, 10)).to be_a(AgnosticBackend::Queryable::Criteria::GreaterAndLess)
    end
  end

  describe '#gt_and_le' do
    it 'should initialize a GreaterAndLessEqual criterion' do
      expect(AgnosticBackend::Queryable::Criteria::GreaterAndLessEqual).to receive(:new).with(attribute: 'an_integer', left_value: 5, right_value: 10, context: context).and_call_original
      expect(subject.gt_and_le('an_integer', 5, 10)).to be_a(AgnosticBackend::Queryable::Criteria::GreaterAndLessEqual)
    end
  end

  describe '#ge_and_lt' do
    it 'should initialize a GreaterEqualAndLess criterion' do
      expect(AgnosticBackend::Queryable::Criteria::GreaterEqualAndLess).to receive(:new).with(attribute: 'an_integer', left_value: 5, right_value: 10, context: context).and_call_original
      expect(subject.ge_and_lt('an_integer', 5, 10)).to be_a(AgnosticBackend::Queryable::Criteria::GreaterEqualAndLess)
    end
  end

  describe '#ge_and_le' do
    it 'should initialize a GreaterEqualAndLessEqual criterion' do
      expect(AgnosticBackend::Queryable::Criteria::GreaterEqualAndLessEqual).to receive(:new).with(attribute: 'an_integer', left_value: 5, right_value: 10, context: context).and_call_original
      expect(subject.ge_and_le('an_integer', 5, 10)).to be_a(AgnosticBackend::Queryable::Criteria::GreaterEqualAndLessEqual)
    end
  end

  describe '#contains' do
    it 'should initialize a Contain criterion' do
      expect(AgnosticBackend::Queryable::Criteria::Contains).to receive(:new).with(attribute: 'a_string', value: 'bar', context: context).and_call_original
      expect(subject.contains('a_string', 'bar')).to be_a(AgnosticBackend::Queryable::Criteria::Contains)
    end
  end

  describe '#starts' do
    it 'should initialize a Starts criterion' do
      expect(AgnosticBackend::Queryable::Criteria::Starts).to receive(:new).with(attribute: 'a_string', value: 'bar', context: context).and_call_original
      expect(subject.starts('a_string', 'bar')).to be_a(AgnosticBackend::Queryable::Criteria::Starts)
    end
  end

  describe '#asc' do
    it 'should initialize a Ascending criterion' do
      expect(AgnosticBackend::Queryable::Operations::Ascending).to receive(:new).with(attribute: 'foo', context: context).and_call_original
      expect(subject.asc('foo')).to be_a(AgnosticBackend::Queryable::Operations::Ascending)
    end
  end

  describe '#desc' do
    it 'should initialize a Descending criterion' do
      expect(AgnosticBackend::Queryable::Operations::Descending).to receive(:new).with(attribute: 'foo', context: context).and_call_original
      expect(subject.desc('foo')).to be_a(AgnosticBackend::Queryable::Operations::Descending)
    end
  end
end