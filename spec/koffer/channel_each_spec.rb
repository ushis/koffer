# frozen_string_literal: true

::RSpec.describe ::Koffer::Channel do
  let(:channel) { described_class.new }

  describe '#each' do
    subject(:trace) { [] }

    before do
      run do
        schedule { trace << [:push, channel.push(1)] }
        schedule { trace << [:push, channel.push(2)] }
        schedule { channel.each { |x| trace << [:pop, x] } }
        schedule { trace << [:push, channel.push(3)] }
        schedule { channel.close }
      end
    end

    it { is_expected.to eq([[:pop, 1], [:pop, 2], [:push, 1], [:push, 2], [:pop, 3], [:push, 3]]) }
  end
end
