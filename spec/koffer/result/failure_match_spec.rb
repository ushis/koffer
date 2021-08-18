# frozen_string_literal: true

::RSpec.describe ::Koffer::Result::Failure do
  let(:result) { described_class.new(:some_error) }

  describe '#match' do
    subject do
      result.match do |m|
        m.failure(:some_error) { :not_ok }
      end
    end

    it { is_expected.to eq(:not_ok) }
  end
end
