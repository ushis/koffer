# frozen_string_literal: true

::RSpec.describe ::Koffer::Result::Success do
  let(:result) { described_class.new }

  describe '#failure?' do
    subject { result.failure? }

    it { is_expected.to eq(false) }
  end
end
