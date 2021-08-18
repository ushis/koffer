# frozen_string_literal: true

::RSpec.describe ::Koffer::Result::Failure do
  let(:result) { described_class.new(:reason) }

  describe '#failure?' do
    subject { result.failure? }

    it { is_expected.to eq(true) }
  end
end
