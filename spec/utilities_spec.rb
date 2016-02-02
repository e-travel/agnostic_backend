require 'spec_helper'

describe AgnosticBackend::Utilities do

  subject do
    Object.send(:remove_const, :DummyObject) if Object.constants.include? :DummyObject
    class DummyObject;
    end
    DummyObject.send(:include, AgnosticBackend::Utilities)
    DummyObject.new
  end

  describe '#flatten' do
    let(:nested_hash) do
      {
          'a' => {
              'b' => {
                  'c' => 1,
                  'd' => 2
              }
          },
          'e' => 3
      }
    end

    it 'should make a flat hash seperated with \'__\'' do
      expect(subject.flatten(nested_hash)).to eq({
                                                     'a__b__c' => 1,
                                                     'a__b__d' => 2,
                                                     'e' => 3
                                                 })

    end

    it 'should counteracted by unflatten function' do
      expect(subject.unflatten(subject.flatten(nested_hash))).to eq nested_hash
    end
  end

  describe '#unflatten' do
    let(:flat_hash) do
      {
          'a__b__c' => 1,
          'a__b__d' => 2,
          'e' => 3
      }
    end

    it 'should make a nested hash with levels in \'__\'' do
      expect(subject.unflatten(flat_hash)).to eq({
                                                     'a' => {
                                                         'b' => {
                                                             'c' => 1,
                                                             'd' => 2
                                                         }
                                                     },
                                                     'e' => 3
                                                 })
    end

    it 'should counteracted by flatten function' do
      expect(subject.flatten(subject.unflatten(flat_hash))).to eq flat_hash
    end
  end

  describe '#transform_nested_values' do
    let(:nested_hash) do
      {
          'a' => {
              'b' => {
                  'c' => [1, 2, 3],
                  'd' => [2, 3, 4]
              }
          },
          'e' => [3, 4, 5]
      }
    end

    it 'should call proc on each value and apply result to the hash' do
      proc = Proc.new{|v| v.first}

      expect(subject.transform_nested_values(nested_hash, proc)).to eq({
                                                                           'a' => {
                                                                               'b' => {
                                                                                   'c' => 1,
                                                                                   'd' => 2
                                                                               }
                                                                           },
                                                                           'e' => 3
                                                                       })

    end
  end

  describe '#value_for_key' do
    let(:nested_hash) do
      {
          'a' => {
              'b' => {
                  'c' => 1,
                  'd' => 2
              }
          },
          'e' => 3
      }
    end

    it 'should return the nested value if key defined' do
      expect(subject.value_for_key(nested_hash, 'a.b.c')).to eq 1
      expect(subject.value_for_key(nested_hash, 'a.b.d')).to eq 2
      expect(subject.value_for_key(nested_hash, 'e')).to eq 3
    end

    it 'should return nil if key not defined' do
      expect(subject.value_for_key(nested_hash, 'a.b')).to be_nil
      expect(subject.value_for_key(nested_hash, 'a.b.c.d')).to be_nil
      expect(subject.value_for_key(nested_hash, '')).to be_nil
    end
  end

  describe '#reject_blank_values_from' do
    let(:flat_document) { {'a' => nil, 'b' => 1, 'c' => [], 'd' => false} }
    it 'should remove key value pairs where value blank and not false' do
      expect(subject.reject_blank_values_from(flat_document)).to eq({'b' => 1, 'd' => false})
    end
  end

  describe '#convert_bool_values_to_string_in' do
    let(:document) { {'a' => true, 'b' => false} }
    it 'should replace boolean values with strings' do
      expect(subject.convert_bool_values_to_string_in(document)).to eq({'a' => 'true', 'b' => 'false'})
    end
  end

  describe '#exponential_backoff_max_time' do
    it 'should return the max time to wait' do
      expect(subject.exponential_backoff_max_time).to eq 4
    end
  end

  describe '#exponential_backoff_sleep_time' do
    before :each do
      srand(0)
    end

    let(:max) { 5 }
    let(:base) { 0.5 }
    it 'should generate a sequence of numbers smaller than max' do
      sequence = (0..4).map{|i| subject.exponential_backoff_sleep_time(max, base, i) }
      expect(sequence.all?{ |time| time <= max }).to be_true
    end

    it 'should generate a sequence of numbers in roughly ascending order' do
      sequence = (0..4).map{ |i| subject.exponential_backoff_sleep_time(max, base, i) }
      expect(sequence).to eq sequence.sort
    end
  end

  describe '#exponential_backoff' do
    let(:block) { Proc.new{ 1 + 2 } }
    let(:max_time) { 0.01 }
    let(:result) { block.call }
    let(:error) { StandardError }

    before do
      allow(subject).to receive(:exponential_backoff_max_time).and_return 0.01
    end

    it 'should call block passed' do
      expect{ |block| subject.with_exponential_backoff(error, &block) }.to yield_control.once
      expect(subject.with_exponential_backoff(error, &block)).to eq result
    end

    it 'should rescue error 10 times' do
      allow(block).to receive(:call).exactly(10).times.and_raise(error)
      allow(block).to receive(:call).and_call_original
      expect{ |block| subject.with_exponential_backoff(error, &block) }.to yield_control.exactly(1).times
      expect(subject.with_exponential_backoff(error, &block)).to eq result
    end

    it 'should raise error if failed 10 times' do
      allow(block).to receive(:call).exactly(11).times.and_raise(error)
      expect{ |block| subject.with_exponential_backoff(error, &block) }.to yield_control.exactly(1).times
      expect{subject.with_exponential_backoff(error, &block)}.to raise_error(error)
    end
  end
end
