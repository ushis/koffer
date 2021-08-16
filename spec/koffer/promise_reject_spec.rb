# frozen_string_literal: true

::RSpec.describe ::Koffer::Promise do
  let(:promise) { described_class.new }

  describe '#reject' do
    let(:error) { ::RuntimeError.new }

    it 'sets the state of the promise' do
      expect { promise.reject(error) }.to change(promise, :state).from(:pending).to(:rejected)
    end

    it 'sets the reason of the promise' do
      expect { promise.reject(error) }.to change(promise, :reason).from(nil).to(error)
    end

    it 'does not set the value of the promise' do
      expect { promise.reject(error) }.not_to change(promise, :value).from(nil)
    end

    context 'when the promise is already resolved' do
      before { promise.resolve(1) }

      it 'does not update the state of the promise' do
        expect { promise.reject(error) }.not_to change(promise, :state).from(:resolved)
      end

      it 'does not update the reason of the promise' do
        expect { promise.reject(error) }.not_to change(promise, :reason).from(nil)
      end

      it 'does not update the value of the promise' do
        expect { promise.reject(error) }.not_to change(promise, :value).from(1)
      end
    end

    context 'when the promise is already rejected' do
      before { promise.reject(other_error) }

      let(:other_error) { ::RuntimeError.new }

      it 'does not update the state of the promise' do
        expect { promise.reject(error) }.not_to change(promise, :state).from(:rejected)
      end

      it 'does not update the reason of the promise' do
        expect { promise.reject(error) }.not_to change(promise, :reason).from(other_error)
      end

      it 'does not update the value of the promise' do
        expect { promise.reject(error) }.not_to change(promise, :value).from(nil)
      end
    end
  end
end
