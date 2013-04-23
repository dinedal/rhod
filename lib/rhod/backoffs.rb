module Rhod::Backoffs

  extend self

  def backoff_sugar_to_enumerator(backoff)
    if backoff.is_a?(Rhod::Backoffs::Backoff)
      backoff
    elsif backoff.is_a?(Numeric)
      Rhod::Backoffs::Constant.new(backoff)
    elsif backoff.is_a?(Range)
      Rhod::Backoffs::Random.new(backoff)
    elsif backoff.is_a?(String)
      n = (backoff[1..-1].to_f)
      case backoff[0]
      when "^"
        Rhod::Backoffs::Exponential.new(n)
      when "l"
        Rhod::Backoffs::Logarithmic.new(n)
      when "r"
        min = backoff[1..-1].split("..")[0].to_f
        max = backoff[1..-1].split("..")[1].to_f
        Rhod::Backoffs::Random.new((min..max))
      end
    elsif backoff.is_a?(Symbol)
      case backoff
      when :^
        Rhod::Backoffs::Exponential.new(0)
      when :l
        Rhod::Backoffs::Logarithmic.new(1.3)
      when :r
        Rhod::Backoffs::Random.new(0..10)
      end
    end
  end

end

require_relative 'backoffs/backoff.rb'
require_relative 'backoffs/constant.rb'
require_relative 'backoffs/exponential.rb'
require_relative 'backoffs/logarithmic.rb'
require_relative 'backoffs/random.rb'
