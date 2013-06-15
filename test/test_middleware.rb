require 'minitest/autorun'
require File.expand_path(File.dirname(__FILE__) + '/helper')

class TestMiddleware
  attr_accessor :_before, :_after, :_error, :_failure

  def initialize(callbacks={}, &block)
    @before = @after = @error = @failure = -> (e) {e}

    %I[before after error failure].each do |cb|
      self.send(:"_#{cb}=", -> (e) {e})
      self.send(:"_#{cb}=", callbacks[cb]) if callbacks[cb]
      self.class.send(:define_method, cb) { |e| self.send(:"_#{cb}").call(e) }
    end

    block.call if block

  end
end

describe Rhod::Middleware do
  it "inits with args passed in" do
    stack = Rhod::Middleware.new
    val = 0

    stack.use(TestMiddleware, before: -> (e) {e[:output] = 1; e}) {val = 1}
    stack.build_stack

    val.must_equal 1

    stack.on_before(output:0)[:output].must_equal 1
  end

  it "calls each callback correctly" do
    %I[before after error failure].each do |cb|
      stack = Rhod::Middleware.new

      stack.use(TestMiddleware, cb => -> (e) {e[:output] = 1; e})
      stack.build_stack

      stack.send(:"on_#{cb}",output:0)[:output].must_equal 1
    end
  end
end
