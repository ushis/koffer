# frozen_string_literal: true

require_relative './promise/util'

module Koffer
  class Promise
    extend Util

    def initialize
      @value = nil
      @state = :pending
      @callbacks = { then: [], rescue: [], finally: [] }.freeze
      @mutex = ::Thread::Mutex.new
      @queue = ::Thread::ConditionVariable.new
    end

    def resolve(value = nil)
      finalize(value, :resolved)
      self
    end

    def reject(reason)
      finalize(reason, :rejected)
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
        raise(@value) if @state == :rejected

        @value
      end
    end

    def value
      @mutex.synchronize { @value if @state == :resolved }
    end

    def reason
      @mutex.synchronize { @value if @state == :rejected }
    end

    def state
      @mutex.synchronize { @state }
    end

    def pending?
      @mutex.synchronize { @state == :pending }
    end

    def resolved?
      @mutex.synchronize { @state == :resolved }
    end

    def rejected?
      @mutex.synchronize { @state == :rejected }
    end

    private

    def finalize(value, state)
      @mutex.synchronize do
        return if @state != :pending

        @value = value
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
      @state == :resolved ? promise.resolve(yield(@value)) : promise.reject(@value)
    rescue ::StandardError => e
      promise.reject(e)
    end

    def run_rescuer(promise)
      @state == :resolved ? promise.resolve(@value) : promise.resolve(yield(@value))
    rescue ::StandardError => e
      promise.reject(e)
    end

    def run_finalizer(promise)
      yield
      @state == :resolved ? promise.resolve(@value) : promise.reject(@value)
    rescue ::StandardError => e
      promise.reject(e)
    end
  end
end
