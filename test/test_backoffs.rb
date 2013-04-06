require 'minitest/autorun'
require File.expand_path(File.dirname(__FILE__) + '/helper')
require 'pry'

describe Rhod::Backoffs do
  describe "backoff_sugar_to_enumerator" do
    it "returns enumerators as is" do
      e = Rhod::Backoffs.constant_backoff(0)
      Rhod::Backoffs.backoff_sugar_to_enumerator(e).must_equal e
    end

    it "generates constant backoffs from a Numeric" do
      Rhod::Backoffs.backoff_sugar_to_enumerator(2.0).next.must_equal 2.0
      Rhod::Backoffs.backoff_sugar_to_enumerator(5).next.must_equal 5
    end

    it "generates expoential backoffs with 'x' syntax" do
      Rhod::Backoffs.backoff_sugar_to_enumerator("x2.0").take(3).must_equal [4.0, 8.0, 16.0]
    end

    it "generates logarithmic backoffs with 'l' syntax" do
      Rhod::Backoffs.backoff_sugar_to_enumerator("l2.0").
        take(3).must_equal [3.169925001442312, 4.0, 4.643856189774724]
    end
  end
end
