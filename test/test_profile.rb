require 'minitest/autorun'
require File.expand_path(File.dirname(__FILE__) + '/helper')

describe Rhod::Profile do
  describe "defaults" do
    it "always has them" do
      assert_instance_of Rhod::Profile, Rhod::Profile.class_variable_get(:@@profiles)[:default]
      defined?(Rhod.with_default).must_equal "method"
      defined?(Rhod::Profile.with_default).must_equal "method"
    end
  end

  describe "self.new" do
    it "copies missing attributes from the defaults" do
      Rhod::Profile.new(:test1, retries: 55 )
      Rhod::Profile.class_variable_get(:@@profiles)[:test1][:retries].must_equal 55
      Rhod::Profile.class_variable_get(:@@profiles)[:test1][:exceptions].must_equal [Exception, StandardError]
    end

    it "creates a new method on itself and the module for new profiles" do
      defined?(Rhod.with_test2).must_equal nil
      defined?(Rhod::Profile.with_test2).must_equal nil

      Rhod::Profile.new(:test2)

      defined?(Rhod.with_test2).must_equal "method"
      defined?(Rhod::Profile.with_test2).must_equal "method"
    end
  end
end
