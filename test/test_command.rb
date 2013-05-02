require 'minitest/autorun'
require File.expand_path(File.dirname(__FILE__) + '/helper')

describe Rhod::Command do
  describe "self.execute" do
    it "runs immediately and returns inner value" do
      Rhod::Command.execute { 1 }.must_equal 1
    end
  end

  describe "execute" do
    it "takes args" do
      Rhod::Command.new(1) {|a| 1 + a}.execute.must_equal 2
    end

    describe "with failures" do

      describe "retrying" do
        it "retries" do
          val = 0

          begin
            Rhod::Command.new(:retries => 1, :backoffs => 0) do
              val += 1
              raise StandardError
            end.execute
          rescue
          end

          val.must_equal 2
        end

        it "uses backoffs" do
          backoff = MiniTest::Mock.new
          backoff.expect(:next, 0)

          Rhod::Backoffs::Constant.stub(:new, backoff) do
            begin
              Rhod::Command.new(:retries => 1, :backoffs => 0) do
                val += 1
                raise StandardError
              end.execute
            rescue
            end
          end
          backoff.verify
        end

      end

      describe "it uses fallbacks" do
        it "triggers fallback on failure" do
          Rhod::Command.new(:fallback => -> { 1 }) {raise StandardError}.execute.must_equal 1
        end

        it "passes args to fallbacks" do
          Rhod::Command.new(1, :fallback => ->(a) { 1 + a }) {raise StandardError}.execute.must_equal 2
        end

        it "only uses fallback after all retries" do
          val = 0

          Rhod::Command.new(
            :retries => 1,
            :backoffs => 0,
            :fallback => -> { 1 }) do
            val += 1
            raise StandardError
          end.execute

          val.must_equal 2
        end
      end
    end

    describe "with connection pools" do
      it "uses the provided pool" do
        pool = ConnectionPool.new(size: 1, timeout: 0) { :conn }
        Rhod::Command.new {|a| a}.execute.must_equal nil
        Rhod::Command.new(pool: pool) {|a| a}.execute.must_equal :conn
      end

      it "correctly handles arguements" do
        pool = ConnectionPool.new(size: 1, timeout: 0) { :conn }
        Rhod::Command.new(1, pool: pool) {|a, b| [a,b]}.execute.must_equal [:conn, 1]
      end
    end

  end
end
