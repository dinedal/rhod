require_relative "rhod/version"
require_relative "rhod/backoffs"
require_relative "rhod/command"

module Rhod
  def self.execute(*args, &block)
    Rhod::Command.execute(*args, &block)
  end

  class << self
    attr_accessor :defaults
  end

  self.defaults = {
    retries: 0,
    backoffs: Rhod::Backoffs.default,
    fallback: nil,
  }

end
