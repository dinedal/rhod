require 'minitest/autorun'
require File.expand_path(File.dirname(__FILE__) + '/helper')

describe Rhod::Command do
  describe "self.execute" do
    it "runs immediately and returns inner value" do
      Rhod::Command.execute { 1 }.must_equal 1
    end
  end

  describe "execute" do
    it "retries requests" do
      val = 0

      begin
        Rhod::Command.new(:retries => 1, :backoffs => Rhod::Backoffs.constant_backoff(0)) do
          val += 1
          raise StandardError
        end.execute
      rescue
      end

      val.must_equal 2
    end
  end
end
