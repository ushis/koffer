# frozen_string_literal: true

require_relative '../result'

module Koffer
  class Result
    class Failure < Result
      attr_reader :reason

      def initialize(reason, **values)
        super(**values)
        @reason = reason
      end

      def failure?
        true
      end
    end
  end
end
