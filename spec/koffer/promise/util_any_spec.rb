# frozen_string_literal: true

::RSpec.describe ::Koffer::Promise::Util do
  let(:util) { ::Object.new.extend(described_class) }

  describe '#any' do
    subject(:promise) { util.any(promises) }

    let(:promises) { [::Koffer::Promise.new, ::Koffer::Promise.new, ::Koffer::Promise.new] }

    context 'when at least one resolves' do
      before do
        run do
          schedule { promise.await }
          schedule { promises[0].reject(::RuntimeError.new) }
          schedule { promises[2].resolve(2) }
          schedule { promises[1].resolve(1) }
        end
      end

      it { is_expected.to have_attributes(state: :resolved, value: 2) }
    end

    context 'when all reject' do
      let(:errors) { [::RuntimeError.new, ::RuntimeError.new, ::RuntimeError.new] }

      before do
        run do
          schedule do
            promise.await
          rescue ::Koffer::Promise::AggregateError
            # ignore
          end

          schedule { promises[0].reject(errors[0]) }
          schedule { promises[2].reject(errors[2]) }
          schedule { promises[1].reject(errors[1]) }
        end
      end

      it { is_expected.to have_attributes(state: :rejected, reason: have_attributes(errors: errors)) }
    end

    context 'without any promises' do
      let(:promises) { [] }

      it { is_expected.to have_attributes(state: :rejected, reason: have_attributes(errors: [])) }
    end

    context 'with one promise already resolved' do
      let(:promises) { [::Koffer::Promise.new, util.resolve(1), util.reject(::RuntimeError.new)] }

      it { is_expected.to have_attributes(state: :resolved, value: 1) }
    end

    context 'with all promises already rejected' do
      let(:promises) { [util.reject(errors[0]), util.reject(errors[1]), util.reject(errors[2])] }
      let(:errors) { [::RuntimeError.new, ::RuntimeError.new, ::RuntimeError.new] }

      it { is_expected.to have_attributes(state: :rejected, reason: have_attributes(errors: errors)) }
    end
  end
end
