# frozen_string_literal: true

module Koffer
  class Result
    class Matcher
      def initialize
        @cases = []
      end

      def success(&block)
        @cases.push([->(result) { result.success? }, block])
      end

      def failure(*reasons, &block)
        @cases.push([->(result) { result.failure? && reasons.include?(result.reason) }, block])
      end

      def call(result)
        _, handler = @cases.find { |(pattern, _)| pattern.call(result) }
        raise "no pattern matched: #{result.inspect}" if handler.nil?

        handler.call(**result.values)
      end
    end
  end
end
