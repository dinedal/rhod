require 'connection_pool'
require_relative "rhod/version"
require_relative "rhod/backoffs"
require_relative "rhod/command"
require_relative "rhod/profile"

module Rhod

  class << self
    attr_accessor :defaults, :connection_pools, :profiles
  end

  def self.execute(*args, &block)
    Rhod.with_default(*args, &block)
  end

  def self.create_profile(options={})
    Rhod::Profile.new(options)
  end

  self.connection_pools = {
    default: ConnectionPool.new(size: 1, timeout: 0) { nil }
  }

end
