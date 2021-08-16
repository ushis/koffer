# frozen_string_literal: true

require 'forwardable'

module Koffer
  class Channel
    class Queue
      extend ::Forwardable

      def initialize
        @queue = []
      end

      def_delegator :@queue, :push
      def_delegator :@queue, :shift, :pop
      def_delegator :@queue, :first, :head
      def_delegator :@queue, :last, :tail
      def_delegator :@queue, :empty?
    end
  end
end
