# frozen_string_literal: true

::RSpec.describe ::Koffer::Promise do
  let(:promise) { described_class.new }

  describe '#resolve' do
    it 'set the state of the promise' do
      expect { promise.resolve(1) }.to change(promise, :state).from(:pending).to(:resolved)
    end

    it 'set the value of the promise' do
      expect { promise.resolve(1) }.to change(promise, :value).from(nil).to(1)
    end

    it 'does not set the reason of the promise' do
      expect { promise.resolve(1) }.not_to change(promise, :reason).from(nil)
    end

    context 'when the promise is already resolved' do
      before { promise.resolve(1) }

      it 'does not update the state of the promise' do
        expect { promise.resolve(2) }.not_to change(promise, :state).from(:resolved)
      end

      it 'does not update the value of the promise' do
        expect { promise.resolve(2) }.not_to change(promise, :value).from(1)
      end

      it 'does not update the reason of the promise' do
        expect { promise.resolve(2) }.not_to change(promise, :reason).from(nil)
      end
    end

    context 'when the promise is already rejected' do
      before { promise.reject(error) }

      let(:error) { ::RuntimeError.new }

      it 'does not update the state of the promise' do
        expect { promise.resolve(2) }.not_to change(promise, :state).from(:rejected)
      end

      it 'does not update the value of the promise' do
        expect { promise.resolve(2) }.not_to change(promise, :value).from(nil)
      end

      it 'does not update the reason of the promise' do
        expect { promise.resolve(2) }.not_to change(promise, :reason).from(error)
      end
    end
  end
end
