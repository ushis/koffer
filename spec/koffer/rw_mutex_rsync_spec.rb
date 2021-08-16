# frozen_string_literal: true

::RSpec.describe ::Koffer::RWMutex do
  let(:mutex) { described_class.new }

  describe '#rsync' do
    subject(:trace) { [] }

    context 'when the mutex is already locked for reading' do
      before do
        run do
          mutex.rsync do
            schedule { mutex.rsync { trace << :read2 } }
            schedule { mutex.rsync { trace << :read3 } }
            trace << :read1
          end
        end
      end

      it { is_expected.to eq([:read2, :read3, :read1]) }
    end

    context 'when the mutex is already locked for writing' do
      before do
        run do
          mutex.sync do
            schedule { mutex.rsync { trace << :read2 } }
            schedule { mutex.rsync { trace << :read3 } }
            trace << :write1
          end
        end
      end

      it { is_expected.to eq([:write1, :read2, :read3]) }
    end

    context 'when the mutex is already locked for reading and writers are pending' do
      before do
        run do
          mutex.rsync do
            schedule { mutex.sync { trace << :write2 } }
            schedule { mutex.rsync { trace << :read3 } }
            schedule { mutex.sync { trace << :write4 } }
            schedule { mutex.rsync { trace << :read5 } }
            trace << :read1
          end
        end
      end

      it { is_expected.to eq([:read1, :write2, :read3, :read5, :write4]) }
    end
  end
end
