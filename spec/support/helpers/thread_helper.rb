# frozen_string_literal: true

require_relative './test_scheduler'

module ThreadHelper
  def run
    ::Thread.new do
      ::Fiber.set_scheduler(::TestSchedulder.new)
      yield
    end.join
  end

  def schedule(&block)
    ::Fiber.schedule(&block)
  end
end
