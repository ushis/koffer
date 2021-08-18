# frozen_string_literal: true

::RSpec.describe ::Koffer::Result::Success do
  let(:result) { described_class.new }

  describe '#success?' do
    subject { result.success? }

    it { is_expected.to eq(true) }
  end
end
