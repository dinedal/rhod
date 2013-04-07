module Rhod::Backoffs

  extend self

  def backoff_sugar_to_enumerator(backoff)
    if backoff.is_a?(Enumerator)
      backoff
    elsif backoff.is_a?(Numeric)
      constant_backoff(backoff)
    elsif backoff.is_a?(Range)
      random_backoffs(backoff)
    elsif backoff.is_a?(String)
      n = (backoff[1..-1].to_f)
      case backoff[0]
      when "^"
        expoential_backoffs(n)
      when "l"
        logarithmic_backoffs(n)
      when "r"
        min = backoff[1..-1].split("..")[0].to_f
        max = backoff[1..-1].split("..")[1].to_f
        random_backoffs((min..max))
      end
    elsif backoff.is_a?(Symbol)
      case backoff
      when :^
        expoential_backoffs
      when :l
        logarithmic_backoffs
      when :r
        random_backoffs
      end
    end
  end

  # Returns a generator of a expoentially increasing series starting at n
  def expoential_backoffs(n=1)
    Enumerator.new do |yielder|
      x = (n - 1)
      loop do
        x += 1
        yielder << 2.0**x
      end
    end
  end

  # Returns a generator of a logarithmicly increasing series starting at n
  def logarithmic_backoffs(n=0.3)
    Enumerator.new do |yielder|
      x = n
      loop do
        x += 1
        yielder << Math.log2(x**2)
      end
    end
  end
  alias default logarithmic_backoffs

  # Always the same backoff
  def constant_backoff(n)
    Enumerator.new do |yielder|
      loop do
        yielder << n
      end
    end
  end

  # Returns a generator of random numbers falling inside of a range
  def random_backoffs(range=(0..10))
    float_range = (range.min.to_f..range.max.to_f)
    Enumerator.new do |yielder|
      loop do
        yielder << rand(float_range)
      end
    end
  end

end
