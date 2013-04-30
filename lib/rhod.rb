require 'connection_pool'
require_relative "rhod/version"
require_relative "rhod/backoffs"
require_relative "rhod/command"
require_relative "rhod/profile"

module Rhod

  def self.execute(*args, &block)
    Rhod.with_default(*args, &block)
  end

  def self.create_profile(name, options={})
    Rhod::Profile.new(name, options)
  end

end
