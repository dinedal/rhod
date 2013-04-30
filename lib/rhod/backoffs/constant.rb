class Rhod::Backoffs::Constant < Rhod::Backoffs::Backoff
  def iterate(state)
    [state, state]
  end
end
