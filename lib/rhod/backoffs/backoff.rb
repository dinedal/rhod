class Rhod::Backoffs::Backoff
  attr_reader :state

  def initialize(state = nil)
    @state = state
  end

  def iterate
    raise NotImplementedError
  end

  def next
    @state, result = iterate(state)
    result
  end
end
