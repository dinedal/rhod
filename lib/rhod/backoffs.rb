module Rhod::Backoffs

  extend self
  # Returns a generator of a expoentially increasing series starting at 1
  def expoential_backoffs
    Enumerator.new do |yielder|
      x = 0
      loop do
        x += 1
        yielder << (1.0/2.0*(2.0**x - 1.0)).ceil
      end
    end
  end

  # Returns a generator of a logarithmicly increasing series starting at 0.3
  def logarithmic_backoffs
    Enumerator.new do |yielder|
      x = 0.3
      loop do
        x += 1
        yielder << Math.log2(x**2)
      end
    end
  end

  # Always the same backoff
  def constant_backoff(i)
    Enumerator.new do |yielder|
      loop do
        yielder << i
      end
    end
  end

  alias default logarithmic_backoffs
end
