# frozen_string_literal: true

require_relative '../result'

module Koffer
  class Result
    class Success < Result
      def success?
        true
      end
    end
  end
end
