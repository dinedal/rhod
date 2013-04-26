require_relative "rhod/version"
require_relative "rhod/backoffs"
require_relative "rhod/command"
require 'connection_pool'

module Rhod

  class << self
    attr_accessor :defaults, :connection_pools, :profiles
  end

  def self.execute(*args, &block)
    Rhod::Command.execute(*args, &block)
  end

  def self.create_profile(name, options={})
    profiles ||= {}
    profiles[name] = options
    self.class.__send__(:define_method, :"with_#{name}") do |*args, &block|
      Rhod::Command.execute(*args, profiles[name], &block)
    end
  end

  self.defaults = {
    retries: 0,
    backoffs: Rhod::Backoffs::Logarithmic.new(1.3),
    fallback: nil,
  }

  self.connection_pools = {
    default: ConnectionPool.new(size: 1, timeout: 0) { nil }
  }

end
