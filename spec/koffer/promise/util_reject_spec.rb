# frozen_string_literal: true

::RSpec.describe ::Koffer::Promise::Util do
  let(:util) { ::Object.new.extend(described_class) }

  describe '#reject' do
    subject { util.reject(error) }

    let(:error) { ::RuntimeError.new }

    it { is_expected.to have_attributes(state: :rejected, reason: error) }
  end
end
