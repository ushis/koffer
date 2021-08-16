# frozen_string_literal: true

::RSpec.describe ::Koffer::Channel do
  let(:channel) { described_class.new }

  describe '#pop' do
    context 'when channel is open' do
      subject(:trace) { [] }

      before do
        run do
          schedule { trace << [:pop, channel.pop] }
          schedule { trace << [:pop, channel.pop] }
          schedule { trace << [:push, channel.push(1)] }
          schedule { trace << [:push, channel.push(2)] }
        end
      end

      it { is_expected.to eq([[:pop, 1], [:pop, 2], [:push, 1], [:push, 2]]) }
    end

    context 'when channel is closed' do
      subject { channel.pop }

      before { channel.close }

      it { is_expected.to eq(nil) }
    end
  end
end
