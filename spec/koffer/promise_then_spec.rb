# frozen_string_literal: true

::RSpec.describe ::Koffer::Promise do
  let(:promise) { described_class.new }

  describe '#then' do
    context 'when the promise resolves' do
      subject! { promise.then { |value| value + 1 } }

      before { promise.resolve(1) }

      it { is_expected.to have_attributes(state: :resolved, value: 2) }
    end

    context 'when the promise resolves and the block raises an error' do
      subject! { promise.then { raise error } }

      before { promise.resolve(1) }

      let(:error) { ::RuntimeError.new }

      it { is_expected.to have_attributes(state: :rejected, reason: error) }
    end

    context 'when the promise rejects' do
      subject! { promise.then { |value| value + 1 } }

      before { promise.reject(error) }

      let(:error) { ::RuntimeError.new }

      it { is_expected.to have_attributes(state: :rejected, reason: error) }
    end

    context 'when the promise rejects and the block raises an error' do
      subject! { promise.then { raise 'other error' } }

      before { promise.reject(error) }

      let(:error) { ::RuntimeError.new }

      it { is_expected.to have_attributes(state: :rejected, reason: error) }
    end

    context 'when the promise is already resolved' do
      subject! { described_class.resolve(2).then { |value| value + 1 } }

      it { is_expected.to have_attributes(state: :resolved, value: 3) }
    end

    context 'when the promise is already rejected' do
      subject! { described_class.reject(error).then { |value| value + 1 } }

      let(:error) { ::RuntimeError.new }

      it { is_expected.to have_attributes(state: :rejected, reason: error) }
    end
  end
end
