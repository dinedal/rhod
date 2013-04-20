require_relative "rhod/version"
require_relative "rhod/backoffs"
require_relative "rhod/command"
require 'connection_pool'

module Rhod
  def self.execute(*args, &block)
    Rhod::Command.execute(*args, &block)
  end

  class << self
    attr_accessor :defaults

    attr_accessor :connection_pools
  end

  self.defaults = {
    retries: 0,
    backoffs: Rhod::Backoffs.default,
    fallback: nil,
    pool: {size: 3, timeout: 5},
  }

  self.connection_pools = {
    default: ConnectionPool.new(size: 1, timeout:0) { nil }
  }

end
