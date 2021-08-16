# frozen_string_literal: true

require_relative './aggregate_error'

module Koffer
  class Promise
    module Util
      def resolve(value)
        Promise.new.resolve(value)
      end

      def reject(reason)
        Promise.new.reject(reason)
      end

      def all(promises)
        return resolve([]) if promises.empty?

        promise = Promise.new

        promises.each do |p|
          p.then { promise.resolve(promises.map(&:value)) if promises.all?(&:resolved?) }
          p.rescue { |reason| promise.reject(reason) }
        end

        promise
      end

      def any(promises)
        return reject(AggregateError.new('All promises were rejected')) if promises.empty?

        promise = Promise.new

        promises.each do |p|
          p.then { |value| promise.resolve(value) }

          p.rescue do
            next unless promises.all?(&:rejected?)

            promise.reject(AggregateError.new('All promises were rejected', errors: promises.map(&:reason)))
          end
        end

        promise
      end

      def all_settled(promises)
        return resolve([]) if promises.empty?

        promise = Promise.new

        promises.each do |p|
          p.finally { promise.resolve(promises) unless promises.any?(&:pending?) }
        end

        promise
      end

      def race(promises)
        promise = Promise.new

        promises.each do |p|
          p.then { |value| promise.resolve(value) }
          p.rescue { |reason| promise.reject(reason) }
        end

        promise
      end
    end
  end
end
