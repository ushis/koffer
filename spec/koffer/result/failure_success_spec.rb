# frozen_string_literal: true

::RSpec.describe ::Koffer::Result::Failure do
  let(:result) { described_class.new(:reason) }

  describe '#success?' do
    subject { result.success? }

    it { is_expected.to eq(false) }
  end
end
