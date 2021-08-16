# frozen_string_literal: true

::RSpec.describe ::Koffer::Promise::Util do
  let(:util) { ::Object.new.extend(described_class) }

  describe '#race' do
    subject(:promise) { util.race(promises) }

    let(:promises) { [::Koffer::Promise.new, ::Koffer::Promise.new, ::Koffer::Promise.new] }

    context 'when the first resolves' do
      before do
        run do
          schedule { promise.await }
          schedule { promises[1].resolve(1) }
        end
      end

      it { is_expected.to have_attributes(state: :resolved, value: 1) }
    end

    context 'when the first rejects' do
      let(:error) { ::RuntimeError.new }

      before do
        run do
          schedule do
            promise.await
          rescue error.class
            # ignore error
          end

          schedule { promises[2].reject(error) }
        end
      end

      it { is_expected.to have_attributes(state: :rejected, reason: error) }
    end

    context 'without any promises' do
      let(:promises) { [] }

      it { is_expected.to have_attributes(state: :pending) }
    end

    context 'when one is already resolved' do
      let(:promises) { [::Koffer::Promise.new, ::Koffer::Promise.new, util.resolve(2)] }

      it { is_expected.to have_attributes(state: :resolved, value: 2) }
    end

    context 'when one is already rejected' do
      let(:promises) { [::Koffer::Promise.new, util.reject(error), ::Koffer::Promise.new] }
      let(:error) { ::RuntimeError.new }

      it { is_expected.to have_attributes(state: :rejected, reason: error) }
    end
  end
end
