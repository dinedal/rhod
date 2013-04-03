require 'minitest/autorun'
require File.expand_path(File.dirname(__FILE__) + '/helper')

describe Rhod::Command do
  describe "execute" do
    it "runs immediately" do
      Rhod::Command.execute { 1 }.must_equal 1
    end
  end
end
