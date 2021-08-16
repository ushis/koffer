# frozen_string_literal: true

::RSpec.describe ::Koffer::Promise do
  let(:promise) { described_class.new }

  describe '#await' do
    context 'when promise resolves' do
      let(:trace) { [] }

      before do
        run do
          schedule { trace << [:await, promise.await] }

          schedule do
            promise.resolve(1)
            trace << [:resolve, 1]
          end
        end
      end

      it 'blocks and returns the value' do
        expect(trace).to eq([[:resolve, 1], [:await, 1]])
      end
    end

    context 'when promise rejects' do
      let(:trace) { [] }
      let(:error) { ::RuntimeError.new }

      before do
        run do
          schedule do
            promise.await
          rescue error.class => e
            trace << [:await, e]
          end

          schedule do
            promise.reject(error)
            trace << [:reject, error]
          end
        end
      end

      it 'blocks and raises the error' do
        expect(trace).to eq([[:reject, error], [:await, error]])
      end
    end

    context 'when the promise is already resolved' do
      before { promise.resolve(1) }

      it 'returns the value immediately' do
        expect(promise.await).to eq(1)
      end
    end

    context 'when the promise is already rejected' do
      before { promise.reject(error) }

      let(:error) { ::RuntimeError.new }

      it 'raises the error immediately' do
        expect { promise.await }.to raise_error(error)
      end
    end
  end
end
