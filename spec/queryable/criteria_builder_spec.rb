require 'spec_helper'

describe AgnosticStore::Queryable::CriteriaBuilder do
  let(:context) { double('context')}
  describe 'initialize' do
    it 'should create context instance variable' do
      builder = AgnosticStore::Queryable::CriteriaBuilder.new(context)
      expect(builder.context).to eq context
    end
  end

  let(:subject) { AgnosticStore::Queryable::CriteriaBuilder.new(context) }
  describe '#not' do
    it 'should initialize a Not operation' do
      expect(AgnosticStore::Queryable::Operations::Not).to receive(:new).with([:a], context).and_call_original
      expect(subject.not(:a)).to be_a(AgnosticStore::Queryable::Operations::Not)
    end
  end

  describe '#and' do
    it 'should initialize an And operation' do
      expect(AgnosticStore::Queryable::Operations::And).to receive(:new).with([:a, :b], context).and_call_original
      expect(subject.and(:a, :b)).to be_a(AgnosticStore::Queryable::Operations::And)
    end
  end

  describe '#all' do
    it 'should initialize an And operation' do
      expect(AgnosticStore::Queryable::Operations::And).to receive(:new).with([:a, :b], context).and_call_original
      expect(subject.all(:a, :b)).to be_a(AgnosticStore::Queryable::Operations::And)
    end
  end

  describe '#any' do
    it 'should initialize an Or operation' do
      expect(AgnosticStore::Queryable::Operations::Or).to receive(:new).with([:a, :b], context).and_call_original
      expect(subject.any(:a, :b)).to be_a(AgnosticStore::Queryable::Operations::Or)
    end
  end

  describe '#or' do
    it 'should initialize an Or operation' do
      expect(AgnosticStore::Queryable::Operations::Or).to receive(:new).with([:a, :b], context).and_call_original
      expect(subject.or(:a, :b)).to be_a(AgnosticStore::Queryable::Operations::Or)
    end
  end

  describe '#eq' do
    it 'should initialize an Equal criterion' do
      expect(AgnosticStore::Queryable::Criteria::Equal).to receive(:new).with([:a, :b], context).and_call_original
      expect(subject.eq(:a, :b)).to be_a(AgnosticStore::Queryable::Criteria::Equal)
    end
  end

  describe '#neq' do
    it 'should initialize a NotEqual criterion' do
      expect(AgnosticStore::Queryable::Criteria::NotEqual).to receive(:new).with([:a, :b], context).and_call_original
      expect(subject.neq(:a, :b)).to be_a(AgnosticStore::Queryable::Criteria::NotEqual)
    end
  end

  describe '#gt' do
    it 'should initialize a Greater criterion' do
      expect(AgnosticStore::Queryable::Criteria::Greater).to receive(:new).with([:a, :b], context).and_call_original
      expect(subject.gt(:a, :b)).to be_a(AgnosticStore::Queryable::Criteria::Greater)
    end
  end

  describe '#lt' do
    it 'should initialize a Less criterion' do
      expect(AgnosticStore::Queryable::Criteria::Less).to receive(:new).with([:a, :b], context).and_call_original
      expect(subject.lt(:a, :b)).to be_a(AgnosticStore::Queryable::Criteria::Less)
    end
  end

  describe '#ge' do
    it 'should initialize a GreaterEqual criterion' do
      expect(AgnosticStore::Queryable::Criteria::GreaterEqual).to receive(:new).with([:a, :b], context).and_call_original
      expect(subject.ge(:a, :b)).to be_a(AgnosticStore::Queryable::Criteria::GreaterEqual)
    end
  end

  describe '#le' do
    it 'should initialize a LessEqual criterion' do
      expect(AgnosticStore::Queryable::Criteria::LessEqual).to receive(:new).with([:a, :b], context).and_call_original
      expect(subject.le(:a, :b)).to be_a(AgnosticStore::Queryable::Criteria::LessEqual)
    end
  end

  describe '#gt_and_lt' do
    it 'should initialize a GreaterAndLess criterion' do
      expect(AgnosticStore::Queryable::Criteria::GreaterAndLess).to receive(:new).with([:a, 5, 10], context).and_call_original
      expect(subject.gt_and_lt(:a, 5, 10)).to be_a(AgnosticStore::Queryable::Criteria::GreaterAndLess)
    end
  end

  describe '#gt_and_le' do
    it 'should initialize a GreaterAndLessEqual criterion' do
      expect(AgnosticStore::Queryable::Criteria::GreaterAndLessEqual).to receive(:new).with([:a, 5, 10], context).and_call_original
      expect(subject.gt_and_le(:a, 5, 10)).to be_a(AgnosticStore::Queryable::Criteria::GreaterAndLessEqual)
    end
  end

  describe '#ge_and_lt' do
    it 'should initialize a GreaterEqualAndLess criterion' do
      expect(AgnosticStore::Queryable::Criteria::GreaterEqualAndLess).to receive(:new).with([:a, 5, 10], context).and_call_original
      expect(subject.ge_and_lt(:a, 5, 10)).to be_a(AgnosticStore::Queryable::Criteria::GreaterEqualAndLess)
    end
  end

  describe '#ge_and_le' do
    it 'should initialize a GreaterEqualAndLessEqual criterion' do
      expect(AgnosticStore::Queryable::Criteria::GreaterEqualAndLessEqual).to receive(:new).with([:a, 5, 10], context).and_call_original
      expect(subject.ge_and_le(:a, 5, 10)).to be_a(AgnosticStore::Queryable::Criteria::GreaterEqualAndLessEqual)
    end
  end

  describe '#contains' do
    it 'should initialize a Contain criterion' do
      expect(AgnosticStore::Queryable::Criteria::Contain).to receive(:new).with([:a, :b], context).and_call_original
      expect(subject.contains(:a, :b)).to be_a(AgnosticStore::Queryable::Criteria::Contain)
    end
  end

  describe '#starts' do
    it 'should initialize a Starts criterion' do
      expect(AgnosticStore::Queryable::Criteria::Start).to receive(:new).with([:a, :b], context).and_call_original
      expect(subject.starts(:a, :b)).to be_a(AgnosticStore::Queryable::Criteria::Start)
    end
  end

  describe '#asc' do
    it 'should initialize a Ascending criterion' do
      expect(AgnosticStore::Queryable::Operations::Ascending).to receive(:new).with([:a], context).and_call_original
      expect(subject.asc(:a)).to be_a(AgnosticStore::Queryable::Operations::Ascending)
    end
  end

  describe '#desc' do
    it 'should initialize a Descending criterion' do
      expect(AgnosticStore::Queryable::Operations::Descending).to receive(:new).with([:a], context).and_call_original
      expect(subject.desc(:a)).to be_a(AgnosticStore::Queryable::Operations::Descending)
    end
  end
end