# frozen_string_literal: true

::RSpec.describe ::Koffer::Result::Success do
  let(:result) { described_class.new }

  describe '#match' do
    subject do
      result.match do |m|
        m.success { :ok }
      end
    end

    it { is_expected.to eq(:ok) }
  end
end
