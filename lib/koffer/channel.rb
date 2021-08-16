# frozen_string_literal: true

require_relative 'channel/closed_error'
require_relative 'channel/queue'
require_relative 'promise'

module Koffer
  class Channel
    def initialize
      @queue = Queue.new
      @mutex = ::Thread::Mutex.new
      @condition = ::Thread::ConditionVariable.new
    end

    def push(value)
      promise = Promise.new

      @mutex.synchronize do
        raise(ClosedError, 'channel closed') if @closed

        @queue.push([promise, value])
        @condition.signal
      end

      promise.await
    end

    def pop
      pop_with_state.first
    end

    def each
      loop do
        value, ok = pop_with_state
        return nil unless ok

        yield(value)
      end
    end

    def close(block: true)
      block ? close_blocking : close_non_blocking
      self
    end

    def closed?
      @mutex.synchronize { @closed }
    end

    private

    def pop_with_state
      @mutex.synchronize do
        while @queue.empty?
          return [nil, false] if @closed

          @condition.wait(@mutex)
        end

        promise, value = @queue.pop
        promise.resolve(value)
        @condition.signal
        [value, true]
      end
    end

    def close_non_blocking
      @mutex.synchronize do
        @closed = true

        until @queue.empty?
          promise, = @queue.pop
          promise.reject(ClosedError.new('channel closed'))
        end

        @condition.broadcast
      end
    end

    def close_blocking
      promise, = @mutex.synchronize do
        @closed = true
        @queue.tail
      end

      promise&.await
    end
  end
end
