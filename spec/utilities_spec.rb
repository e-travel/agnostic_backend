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
      expect(sequence.all?{ |time| time <= max }).to be true
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

  describe '#is_integer?' do
    context 'given an integer' do
      let(:value) { 1 }
      it 'should return true' do
        expect(subject.is_integer?(value)).to be true
      end
    end

    context 'given a string' do
      context 'when string has an integer format' do
        let(:value) { '1' }
        it 'should return true' do
          expect(subject.is_integer?(value)).to be true
        end
      end

      context 'when string does not have an integer format' do
        let(:value) { '1.1' }
        it 'should return false' do
          expect(subject.is_integer?(value)).to be false
        end
      end
    end
  end

  describe '#is_float?' do
    context 'given an integer' do
      let(:value) { 1 }
      it 'should return true' do
        expect(subject.is_float?(value)).to be true
      end
    end

    context 'given a float' do
      let(:value) { 1.1 }
      it 'should return true' do
        expect(subject.is_float?(value)).to be true
      end
    end

    context 'given a string' do
      context 'when string has a float format' do
        let(:value) { '1.1' }
        it 'should return true' do
          expect(subject.is_float?(value)).to be true
        end
      end

      context 'when string does not have an integer format' do
        let(:value) { '1.1.2' }
        it 'should return false' do
          expect(subject.is_float?(value)).to be false
        end
      end
    end
  end

  describe '#is_boolean?' do
    context 'given a string' do
      context 'when string has a boolean value' do
        let(:value) { 'true' }
        it 'should return true' do
          expect(subject.is_boolean?(value)).to be true
        end

        let(:value) { 'false' }
        it 'should return true' do
          expect(subject.is_boolean?(value)).to be true
        end
      end

      context 'when string does not have an boolean value' do
        let(:value) { 'not' }
        it 'should return false' do
          expect(subject.is_boolean?(value)).to be false
        end
      end
    end
  end

  describe '#is_date?' do
    context 'given a string' do
      context 'when string has a date format' do
        let(:value) { '10-02-2016 16:13' }
        it 'should return true' do
          expect(subject.is_date?(value)).to be true
        end
      end

      context 'when string has a date format' do
        let(:value) { '2016-02-10T16:15:03+02:00' }
        it 'should return true' do
          expect(subject.is_date?(value)).to be true
        end
      end

      context 'when string does not have a date value' do
        let(:value) { 'date' }
        it 'should return false' do
          expect(subject.is_date?(value)).to be false
        end
      end
    end
  end

  describe '#is_date?' do
    context 'given a string' do
      context 'when string has a date format' do
        let(:value) { '10-02-2016 16:13' }
        it 'should return true' do
          expect(subject.is_date?(value)).to be true
        end
      end

      context 'when string has a date format' do
        let(:value) { '2016-02-10T16:15:03+02:00' }
        it 'should return true' do
          expect(subject.is_date?(value)).to be true
        end
      end

      context 'when string does not have a date value' do
        let(:value) { 'date' }
        it 'should return false' do
          expect(subject.is_date?(value)).to be false
        end
      end
    end
  end

  describe '#convert_to_boolean' do
    context 'when \'false\' is given' do
      let(:value) { 'false' }
      it 'should return false' do
        expect(subject.convert_to_boolean(value)).to be false
      end
    end

    context 'when \'true\' is given' do
      let(:value) { 'true' }
      it 'should return true' do
        expect(subject.convert_to_boolean(value)).to be true
      end
    end
  end

  describe '#convert_to' do
    context 'when type is integer' do
      let(:type) { :integer }
      context 'when value is an integer' do
        let(:value) { 1 }
        it 'should return the value' do
          result = subject.convert_to(type, value)
          expect(result).to be_a Fixnum
          expect(result).to eq 1
        end
      end

      context 'when value can be converted to integer' do
        let(:value) { '1' }
        it 'should return the value converted to integer' do
          result = subject.convert_to(type, value)
          expect(result).to be_a Fixnum
          expect(result).to eq 1
        end
      end

      context 'when value cannot be converted to integer' do
        let(:value) { '1.1' }
        it 'should return the value' do
          result = subject.convert_to(type, value)
          expect(result).not_to be_a Fixnum
          expect(result).to eq value
        end
      end
    end

    context 'when type is date' do
      let(:type) { :date }
      context 'when value is an date' do
        let(:value) { Time.now }
        it 'should return the value' do
          result = subject.convert_to(type, value)
          expect(result).to be_a Time
          expect(result).to eq value.utc
        end
      end

      context 'when value can be converted to date' do
        let(:value) { '2016-02-10T16:15:03+02:00' }
        it 'should return the value converted to date' do
          result = subject.convert_to(type, value)
          expect(result).to be_a Time
          expect(result).to eq value.to_time.utc
        end
      end

      context 'when value cannot be converted to date' do
        let(:value) { 'date' }
        it 'should return the value' do
          result = subject.convert_to(type, value)
          expect(result).not_to be_a Time
          expect(result).to eq value
        end
      end
    end

    context 'when type is double' do
      let(:type) { :double }
      context 'when value is an float' do
        let(:value) { 1.1 }
        it 'should return the value' do
          result = subject.convert_to(type, value)
          expect(result).to be_a Float
          expect(result).to eq 1.1
        end
      end

      context 'when value is an integer' do
        let(:value) { 1 }
        it 'should return the value' do
          result = subject.convert_to(type, value)
          expect(result).to be_a Float
          expect(result).to eq 1.0
        end
      end

      context 'when value can be converted to float' do
        let(:value) { '1.1' }
        it 'should return the value converted to float' do
          result = subject.convert_to(type, value)
          expect(result).to be_a Float
          expect(result).to eq 1.1
        end
      end

      context 'when value cannot be converted to float' do
        let(:value) { '1a' }
        it 'should return the value' do
          result = subject.convert_to(type, value)
          expect(result).not_to be_a Fixnum
          expect(result).to eq value
        end
      end
    end

    context 'when type is boolean' do
      let(:type) { :boolean }
      context 'when value is an boolean' do
        let(:value) { false }
        it 'should return the value' do
          result = subject.convert_to(type, value)
          expect(result).to be_a FalseClass
          expect(result).to eq value
        end
      end

      context 'when value can be converted to boolean' do
        let(:value) { 'false' }
        it 'should return the value converted to boolean' do
          result = subject.convert_to(type, value)
          expect(result).to be_a FalseClass
        end
      end

      context 'when value cannot be converted to boolean' do
        let(:value) { 'Not' }
        it 'should return the value' do
          result = subject.convert_to(type, value)
          expect(result).not_to be_a FalseClass
          expect(result).to eq value
        end
      end
    end

    context 'when type is string' do
      let(:type) { :string }
      context 'when value is an string' do
        let(:value) { 'string' }
        it 'should return the value' do
          result = subject.convert_to(type, value)
          expect(result).to be_a String
          expect(result).to eq value
        end
      end

      context 'when value can be converted to string' do
        let(:value) { 10.0 }
        it 'should return the value converted to string' do
          result = subject.convert_to(type, value)
          expect(result).to be_a String
          expect(result).to eq value.to_s
        end
      end
    end

    context 'when type is nil' do
      let(:type) { nil }
      let(:value) { 10.0 }
      it 'should return the value' do
        result = subject.convert_to(type, value)
        expect(result).to be_a value.class
        expect(result).to eq value
      end
    end
  end
end
