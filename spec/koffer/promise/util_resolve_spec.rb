# frozen_string_literal: true

::RSpec.describe ::Koffer::Promise::Util do
  let(:util) { ::Object.new.extend(described_class) }

  describe '#resolve' do
    subject { util.resolve(1) }

    it { is_expected.to have_attributes(state: :resolved, value: 1) }
  end
end
