# frozen_string_literal: true

require_relative './promise/util'

module Koffer
  class Promise
    extend Util

    attr_reader :value, :reason, :state

    def initialize
      @value = nil
      @reason = nil
      @state = :pending
      @callbacks = { then: [], rescue: [], finally: [] }.freeze
      @mutex = ::Thread::Mutex.new
      @queue = ::Thread::ConditionVariable.new
    end

    def resolve(value = nil)
      finalize(value, nil, :resolved)
      self
    end

    def reject(reason)
      finalize(nil, reason, :rejected)
      self
    end

    def then(&block)
      promise = Promise.new
      add_callback(:then, promise, &block) || run_resolver(promise, &block)
      promise
    end

    def rescue(&block)
      promise = Promise.new
      add_callback(:rescue, promise, &block) || run_rescuer(promise, &block)
      promise
    end

    def finally(&block)
      promise = Promise.new
      add_callback(:finally, promise, &block) || run_finalizer(promise, &block)
      promise
    end

    def await
      @mutex.synchronize do
        @queue.wait(@mutex) while @state == :pending
        raise(@reason) if @state == :rejected

        @value
      end
    end

    def pending?
      @state == :pending
    end

    def resolved?
      @state == :resolved
    end

    def rejected?
      @state == :rejected
    end

    private

    def finalize(value, reason, state)
      @mutex.synchronize do
        return if @state != :pending

        @value = value
        @reason = reason
        @state = state
        freeze
        @queue.broadcast
      end

      run_callbacks
    end

    def freeze
      @callbacks.each(&:freeze)
      super
    end

    def add_callback(name, promise, &block)
      @mutex.synchronize do
        return false unless @state == :pending

        @callbacks[name].push([promise, block])
      end
    end

    def run_callbacks
      @callbacks[:then].each { |(promise, block)| run_resolver(promise, &block) }
      @callbacks[:rescue].each { |(promise, block)| run_rescuer(promise, &block) }
      @callbacks[:finally].each { |(promise, block)| run_finalizer(promise, &block) }
    end

    def run_resolver(promise)
      @state == :resolved ? promise.resolve(yield(@value)) : promise.reject(@reason)
    rescue ::StandardError => e
      promise.reject(e)
    end

    def run_rescuer(promise)
      @state == :resolved ? promise.resolve(@value) : promise.resolve(yield(@reason))
    rescue ::StandardError => e
      promise.reject(e)
    end

    def run_finalizer(promise)
      yield
      @state == :resolved ? promise.resolve(@value) : promise.reject(@reason)
    rescue ::StandardError => e
      promise.reject(e)
    end
  end
end
