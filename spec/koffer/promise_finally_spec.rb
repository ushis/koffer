# frozen_string_literal: true

::RSpec.describe ::Koffer::Promise do
  let(:promise) { described_class.new }

  describe '#finally' do
    context 'when the promise resolves' do
      subject! { promise.finally { trace << :finally } }

      before do
        promise.resolve(1)
        trace << :resolve
      end

      let(:trace) { [] }

      it { is_expected.to have_attributes(state: :resolved, value: 1) }

      it 'executes the block' do
        expect(trace).to eq([:finally, :resolve])
      end
    end

    context 'when the promise resolves and the block raises an error' do
      subject! { promise.finally { raise 'some error' } }

      before { promise.resolve(1) }

      it { is_expected.to have_attributes(state: :rejected, reason: have_attributes(message: 'some error')) }
    end

    context 'when the promise rejects' do
      subject! { promise.finally { trace << :finally } }

      before do
        promise.reject(error)
        trace << :reject
      end

      let(:trace) { [] }
      let(:error) { ::RuntimeError.new }

      it { is_expected.to have_attributes(state: :rejected, reason: error) }

      it 'executes the block' do
        expect(trace).to eq([:finally, :reject])
      end
    end

    context 'when the promise rejects and the block raises an error' do
      subject! { promise.finally { raise 'other error' } }

      before { promise.reject(::RuntimeError.new('some error')) }

      it { is_expected.to have_attributes(state: :rejected, reason: have_attributes(message: 'other error')) }
    end

    context 'when the promise is already resolved' do
      subject! { described_class.resolve(2).finally { trace << :finally } }

      let(:trace) { [] }

      it { is_expected.to have_attributes(state: :resolved, value: 2) }

      it 'executes the block' do
        expect(trace).to eq([:finally])
      end
    end

    context 'when the promise is already rejected' do
      subject! { described_class.reject(error).finally { trace << :finally } }

      let(:trace) { [] }
      let(:error) { ::RuntimeError.new }

      it { is_expected.to have_attributes(state: :rejected, reason: error) }

      it 'executes the block' do
        expect(trace).to eq([:finally])
      end
    end
  end
end
