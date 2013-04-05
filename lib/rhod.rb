require_relative "rhod/version"
require_relative "rhod/backoffs"
require_relative "rhod/command"

module Rhod
  def self.execute(*args, &block)
    Rhod::Command.execute(*args, &block)
  end
end
