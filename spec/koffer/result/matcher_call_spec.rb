# frozen_string_literal: true

::RSpec.describe ::Koffer::Result::Matcher do
  let(:matcher) { described_class.new }

  describe '#call' do
    subject { matcher.call(result) }

    before do
      matcher.success { |a:, b:| [:success, a, b] }
      matcher.failure(:c) { |d:| [:failure, :c, d] }
      matcher.failure(:e, :f) { [:failure, :e, :f] }
    end

    context 'with success' do
      let(:result) { ::Koffer::Result::Success.new(a: 1, b: 2) }

      it { is_expected.to eq([:success, 1, 2]) }
    end

    context 'with failure :c' do
      let(:result) { ::Koffer::Result::Failure.new(:c, d: 3) }

      it { is_expected.to eq([:failure, :c, 3]) }
    end

    context 'with failure :e' do
      let(:result) { ::Koffer::Result::Failure.new(:e) }

      it { is_expected.to eq([:failure, :e, :f]) }
    end

    context 'with failure :f' do
      let(:result) { ::Koffer::Result::Failure.new(:f) }

      it { is_expected.to eq([:failure, :e, :f]) }
    end

    context 'with failure :g' do
      let(:result) { ::Koffer::Result::Failure.new(:g) }

      it 'raises an error' do
        expect { matcher.call(result) }.to raise_error(::RuntimeError)
      end
    end
  end
end
