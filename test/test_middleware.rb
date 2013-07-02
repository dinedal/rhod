require 'minitest/autorun'
require File.expand_path(File.dirname(__FILE__) + '/helper')

class TestMiddleware
  def initialize(params=nil)
    @opts = params
  end

  def on(event, env)
    env
  end
end

describe Rhod::Middleware do
  it "inits with args passed in" do
    stack = Rhod::Middleware.new

    stack.use(TestMiddleware, 1)
    stack.build_stack

    stack.instance_eval{@stack}.first.instance_eval{@opts}.must_equal 1
  end

  it "calls each callback correctly" do
    %I[before after error failure].each do |event|
      stack = Rhod::Middleware.new

      stack.use(TestMiddleware)
      stack.build_stack

      stack.send(:on, event, output: 0)[:output].must_equal 0
    end
  end
end
