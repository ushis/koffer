# frozen_string_literal: true

::RSpec.describe ::Koffer::Promise::Util do
  let(:util) { ::Object.new.extend(described_class) }

  describe '#all_settled' do
    subject(:promise) { util.all_settled(promises) }

    let(:promises) { [::Koffer::Promise.new, ::Koffer::Promise.new, ::Koffer::Promise.new] }

    context 'when all settle' do
      before do
        run do
          schedule { promise.await }
          schedule { promises[0].resolve(0) }
          schedule { promises[2].resolve(2) }
          schedule { promises[1].reject(::RuntimeError.new) }
        end
      end

      it { is_expected.to have_attributes(state: :resolved, value: promises) }
    end

    context 'without any promises' do
      let(:promises) { [] }

      it { is_expected.to have_attributes(state: :resolved, value: []) }
    end

    context 'when all are already settled' do
      let(:promises) { [util.resolve(0), util.resolve(1), util.resolve(2)] }

      it { is_expected.to have_attributes(state: :resolved, value: promises) }
    end

    context 'when one is pending' do
      let(:promises) { [::Koffer::Promise.new, util.reject(error), util.resolve(2)] }
      let(:error) { ::RuntimeError.new }

      it { is_expected.to have_attributes(state: :pending) }
    end
  end
end
