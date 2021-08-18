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
      @resolvers = []
      @rescuers = []
      @finalizers = []
      @mutex = ::Thread::Mutex.new
      @queue = ::Thread::ConditionVariable.new
    end

    def resolve(value = nil)
      settle(value, nil, :resolved)
      self
    end

    def reject(reason)
      settle(nil, reason, :rejected)
      self
    end

    def then(&block)
      promise = Promise.new
      add_callback(@resolvers, promise, &block) || run_resolver(promise, &block)
      promise
    end

    def rescue(&block)
      promise = Promise.new
      add_callback(@rescuers, promise, &block) || run_rescuer(promise, &block)
      promise
    end

    def finally(&block)
      promise = Promise.new
      add_callback(@finalizers, promise, &block) || run_finalizer(promise, &block)
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

    def settled?
      @state != :pending
    end

    def resolved?
      @state == :resolved
    end

    def rejected?
      @state == :rejected
    end

    private

    def settle(value, reason, state)
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
      @resolvers.freeze
      @rescuers.freeze
      @finalizers.freeze
      super
    end

    def add_callback(chain, promise, &block)
      @mutex.synchronize do
        return false unless @state == :pending

        chain.push([promise, block])
      end
    end

    def run_callbacks
      @resolvers.each { |(promise, block)| run_resolver(promise, &block) }
      @rescuers.each { |(promise, block)| run_rescuer(promise, &block) }
      @finalizers.each { |(promise, block)| run_finalizer(promise, &block) }
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
