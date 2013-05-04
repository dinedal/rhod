class Rhod::Middleware
  def use(middleware, *args, &block)
    self.stack << [middleware, args, block]
  end

  protected
  def stack
    @stack ||= []
  end
end
