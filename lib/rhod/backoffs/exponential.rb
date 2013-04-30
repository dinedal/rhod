class Rhod::Backoffs::Exponential < Rhod::Backoffs::Backoff
  def iterate(state)
    [state + 1, 2.0**(state)]
  end
end
