# frozen_string_literal: true

require_relative './result/matcher'

module Koffer
  class Result
    attr_reader :values

    def initialize(**values)
      @values = values
    end

    def [](key)
      @values[key]
    end

    def success?
      false
    end

    def failure?
      false
    end

    def match
      matcher = Matcher.new
      yield(matcher)
      matcher.call(self)
    end
  end
end
