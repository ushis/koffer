# frozen_string_literal: true

::RSpec.describe ::Koffer::Result::Failure do
  let(:result) { described_class.new(:some_reason) }

  describe '#reason' do
    subject { result.reason }

    it { is_expected.to eq(:some_reason) }
  end
end
