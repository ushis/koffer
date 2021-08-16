# frozen_string_literal: true

::RSpec.describe ::Koffer::Promise do
  let(:promise) { described_class.new }

  describe '#rescue' do
    context 'when the promise resolves' do
      subject! { promise.rescue { |reason| "recovered from #{reason.message}" } }

      before { promise.resolve(1) }

      it { is_expected.to have_attributes(state: :resolved, value: 1) }
    end

    context 'when the promise resolves and the block raises an error' do
      subject! { promise.rescue { |reason| raise reason } }

      before { promise.resolve(1) }

      it { is_expected.to have_attributes(state: :resolved, value: 1) }
    end

    context 'when the promise rejects' do
      subject! { promise.rescue { |reason| "recovered from #{reason.message}" } }

      before { promise.reject(::RuntimeError.new('total failure')) }

      it { is_expected.to have_attributes(state: :resolved, value: 'recovered from total failure') }
    end

    context 'when the promise rejects and the block raises an error' do
      subject! { promise.rescue { |reason| raise "failed: #{reason.message}" } }

      before { promise.reject(::RuntimeError.new('total failure')) }

      it { is_expected.to have_attributes(state: :rejected, reason: have_attributes(message: 'failed: total failure')) }
    end

    context 'when the promise is already resolved' do
      subject! { described_class.resolve(1).rescue { |reason| "recovered from #{reason.message}" } }

      it { is_expected.to have_attributes(state: :resolved, value: 1) }
    end

    context 'when the promise is already rejected' do
      subject! { described_class.reject(error).rescue { |reason| "recovered from #{reason.message}" } }

      let(:error) { ::RuntimeError.new('total failure') }

      it { is_expected.to have_attributes(state: :resolved, value: 'recovered from total failure') }
    end
  end
end
