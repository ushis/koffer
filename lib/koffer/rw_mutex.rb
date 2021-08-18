# frozen_string_literal: true

module Koffer
  class RWMutex
    def initialize
      @mutex = ::Thread::Mutex.new
      @r_queue = ::Thread::ConditionVariable.new
      @w_queue = ::Thread::ConditionVariable.new
      @r_count = 0
      @w_count = 0
      @r_wait = 0
      @w_wait = 0
    end

    def rlock
      @mutex.synchronize do
        @r_wait += 1
        @r_queue.wait(@mutex) if @w_wait > 0
        @r_queue.wait(@mutex) while @w_count > 0
        @r_count += 1
        @r_wait -= 1
      end
    end

    def runlock
      @mutex.synchronize do
        raise(::ThreadError, 'Attempt to unlock a mutex which is not locked') if @r_count < 1

        @r_count -= 1
        @w_queue.signal if @r_count == 0
      end
    end

    def rsync
      rlock

      begin
        yield
      ensure
        runlock
      end
    end

    def lock
      @mutex.synchronize do
        @w_wait += 1
        @w_queue.wait(@mutex) while @w_count > 0 || @r_count > 0
        @w_count += 1
        @w_wait -= 1
      end
    end

    def unlock
      @mutex.synchronize do
        raise(::ThreadError, 'Attempt to unlock a mutex which is not locked') if @w_count < 1

        @w_count -= 1
        @r_queue.broadcast
        @w_queue.signal
      end
    end

    def sync
      lock

      begin
        yield
      ensure
        unlock
      end
    end

    def inspect
      "#<RWMutex w_wait: #{@w_wait} w_count: #{@w_count} r_wait: #{@r_wait} r_count: #{@r_count}>"
    end
  end
end
