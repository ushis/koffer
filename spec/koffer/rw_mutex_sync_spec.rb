# frozen_string_literal: true

::RSpec.describe ::Koffer::RWMutex do
  let(:mutex) { described_class.new }

  describe '#sync' do
    subject(:trace) { [] }

    context 'when the mutex is already locked for reading' do
      before do
        run do
          mutex.rsync do
            schedule { mutex.sync { trace << :write2 } }
            schedule { mutex.sync { trace << :write3 } }
            trace << :read1
          end
        end
      end

      it { is_expected.to eq([:read1, :write2, :write3]) }
    end

    context 'when the mutex is already locked for writing' do
      before do
        run do
          mutex.sync do
            schedule { mutex.sync { trace << :write2 } }
            schedule { mutex.sync { trace << :write3 } }
            trace << :write1
          end
        end
      end

      it { is_expected.to eq([:write1, :write2, :write3]) }
    end
  end
end
