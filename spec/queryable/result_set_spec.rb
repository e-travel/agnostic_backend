require 'spec_helper'

describe AgnosticBackend::Queryable::ResultSet do

  subject do
    AgnosticBackend::Queryable::ResultSet.new(raw_results, query)
  end

  let(:raw_results) { double('raw_results')}
  let(:query) { double('query') }

  it { should be_a Enumerable }

  describe '#total_count' do
    it 'should be abstract' do
      expect { subject.total_count }.to raise_error NotImplementedError
    end
  end

  describe '#offset' do
    it 'should be abstract' do
      expect { subject.offset }.to raise_error NotImplementedError
    end
  end

  describe '#each' do
    let(:result_1) { {'a' => {'b' => 1}} }
    let(:result_2) { {'a' => {'c' => 2}} }
    let(:filtered_results) {
      [
          result_1,
          result_2
      ]
    }

    it 'should call each on filtered_results' do
      expect(subject).to receive(:filtered_results).and_return filtered_results
      expect(filtered_results).to receive(:each)
      subject.each
    end

    it 'should yield transformed result' do
      expect(subject).to receive(:filtered_results).and_return filtered_results
      expect(subject).to receive(:transform).with(result_1).and_return result_1
      expect(subject).to receive(:transform).with(result_2).and_return result_2

      expect{ |b| subject.each(&b) }.to yield_successive_args(
                                            {'a' =>
                                                 {'b' => 1}
                                            },
                                            {'a' =>
                                                 {'c' => 2}
                                            }
                                        )
    end
  end

  describe '#filtered_results' do
    it 'should be abstract' do
      expect { subject.send(:filtered_results) }.to raise_error NotImplementedError
    end
  end

  describe '#transform' do
    let(:result) { 'result' }
    it 'should be abstract' do
      expect { subject.send(:transform, result) }.to raise_error NotImplementedError
    end
  end

  describe '#empty?' do
    context 'when empty result' do
      let(:filtered_results) { [] }
      before do
        expect(subject).to receive(:filtered_results).and_return filtered_results
      end
      it 'should return true' do
        expect(subject.send(:empty?)).to be true
      end
    end

    context 'when non empty result' do
      let(:result_1) { {'a' => {'b' => 1}} }
      let(:result_2) { {'a' => {'c' => 2}} }
      let(:filtered_results) {
        [
            result_1,
            result_2
        ]
      }

      before do
        expect(subject).to receive(:filtered_results).and_return filtered_results
        allow(subject).to receive(:transform).with(result_1).and_return result_1
        allow(subject).to receive(:transform).with(result_2).and_return result_2
      end

      it 'should return false' do
        expect(subject.send(:empty?)).to be false
      end
    end
  end
end