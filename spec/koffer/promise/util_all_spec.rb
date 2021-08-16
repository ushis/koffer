# frozen_string_literal: true

::RSpec.describe ::Koffer::Promise::Util do
  let(:util) { ::Object.new.extend(described_class) }

  describe '#all' do
    subject(:promise) { util.all(promises) }

    let(:promises) { [::Koffer::Promise.new, ::Koffer::Promise.new, ::Koffer::Promise.new] }

    context 'when all resolve' do
      before do
        run do
          schedule { promise.await }
          schedule { promises[0].resolve(0) }
          schedule { promises[2].resolve(2) }
          schedule { promises[1].resolve(1) }
        end
      end

      it { is_expected.to have_attributes(state: :resolved, value: [0, 1, 2]) }
    end

    context 'when one rejects' do
      let(:error) { ::RuntimeError.new }

      before do
        run do
          schedule do
            promise.await
          rescue error.class
            # ignore error
          end

          schedule { promises[0].resolve(0) }
          schedule { promises[1].reject(error) }
        end
      end

      it { is_expected.to have_attributes(state: :rejected, reason: error) }
    end

    context 'without any promises' do
      let(:promises) { [] }

      it { is_expected.to have_attributes(state: :resolved, value: []) }
    end

    context 'when all are already resolved' do
      let(:promises) { [util.resolve(0), util.resolve(1), util.resolve(2)] }

      it { is_expected.to have_attributes(state: :resolved, value: [0, 1, 2]) }
    end

    context 'when one is already rejected' do
      let(:promises) { [::Koffer::Promise.new, util.reject(error), ::Koffer::Promise.new] }
      let(:error) { ::RuntimeError.new }

      it { is_expected.to have_attributes(state: :rejected, reason: error) }
    end
  end
end
