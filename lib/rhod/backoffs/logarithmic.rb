class Rhod::Backoffs::Logarithmic < Rhod::Backoffs::Backoff
  def iterate(state)
    [state + 1, Math.log2((state)**2)]
  end
end
