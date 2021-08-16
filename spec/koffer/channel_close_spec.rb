# frozen_string_literal: true

::RSpec.describe ::Koffer::Channel do
  let(:channel) { described_class.new }

  describe '#close' do
    subject(:trace) { [] }

    context 'with blocking enabled' do
      before do
        run do
          schedule { trace << [:push, channel.push(1)] }

          schedule do
            channel.close
            trace << [:close]
          end

          schedule { trace << [:pop, channel.pop] }
          schedule { trace << [:pop, channel.pop] }

          schedule do
            channel.push(2)
          rescue ::Koffer::Channel::ClosedError
            trace << [:push_2_failed]
          end
        end
      end

      it { is_expected.to eq([[:pop, 1], [:pop, nil], [:push_2_failed], [:push, 1], [:close]]) }
    end

    context 'with blocking disabled and unread values' do
      before do
        run do
          schedule do
            channel.push(1)
          rescue ::Koffer::Channel::ClosedError
            trace << [:push_1_failed]
          end

          schedule do
            channel.push(2)
          rescue ::Koffer::Channel::ClosedError
            trace << [:push_2_failed]
          end

          schedule do
            channel.close(block: false)
            trace << [:close]
          end
        end
      end

      it { is_expected.to eq([[:close], [:push_1_failed], [:push_2_failed]]) }
    end

    context 'with blocking disabled and pending pops' do
      before do
        run do
          schedule { trace << [:pop, channel.pop] }
          schedule { trace << [:pop, channel.pop] }

          schedule do
            channel.close(block: false)
            trace << [:close]
          end
        end
      end

      it { is_expected.to eq([[:close], [:pop, nil], [:pop, nil]]) }
    end
  end
end
