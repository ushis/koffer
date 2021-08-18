# frozen_string_literal: true

::RSpec.describe ::Koffer::Result::Success do
  let(:result) { described_class.new(**values) }

  describe '#values' do
    subject { result.values }

    let(:values) { { a: 1, b: 2 } }

    it { is_expected.to eq(values) }
  end

  describe '#[]' do
    subject { result[key] }

    let(:values) { { a: 1, b: 2 } }

    context 'when value is present' do
      let(:key) { :a }

      it { is_expected.to eq(1) }
    end

    context 'when value is missing' do
      let(:key) { :c }

      it { is_expected.to eq(nil) }
    end
  end
end
