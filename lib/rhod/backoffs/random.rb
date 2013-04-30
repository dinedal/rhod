class Rhod::Backoffs::Random < Rhod::Backoffs::Backoff
  def iterate(state)
    @float_range ||= (state.min.to_f..state.max.to_f)
    [@float_range, rand(@float_range)]
  end
end
