# frozen_string_literal: true

require_relative '../error'

module Koffer
  class Promise
    class AggregateError < Error
      attr_reader :errors

      def initialize(msg = nil, errors: [])
        super(msg)
        @errors = errors
      end
    end
  end
end
