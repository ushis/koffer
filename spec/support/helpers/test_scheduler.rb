# frozen_string_literal: true

class ::TestSchedulder
  def initialize
    @ready_queue = ::Thread::Queue.new
    @blocking_count = 0
  end

  def close
    loop do
      @ready_queue.pop(true).resume
    rescue ::ThreadError
      break
    end

    raise(::ThreadError, 'deadlock') if @blocking_count > 0
  end

  def fiber(&block)
    fiber = ::Fiber.new(blocking: false, &block)
    fiber.resume
    fiber
  end

  def kernel_sleep(duration = nil)
    raise(::NotImplementedError, 'sleep with duration is not implemented') unless duration.nil?

    block(:sleep)
  end

  def block(_, _ = nil)
    @blocking_count += 1
    ::Fiber.yield
    @blocking_count -= 1
  end

  def unblock(_, fiber)
    @ready_queue.push(fiber)
  end
end
