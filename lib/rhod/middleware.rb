class Rhod::Middleware
  class Rhod::InvalidMiddleware < Exception; end

  def initialize
    @stack = []
  end

  def use(middleware, *args, &block)
    @stack << [middleware, args, block]
  end

  def build_stack
    @stack = @stack.map do |current_middleware|
      klass, args, block = current_middleware

      if klass.is_a?(Class)
        klass.new(*args, &block)
      else
        raise Rhod::InvalidMiddleware, "Unable to call middleware #{current_middleware}"
      end
    end
  end

  def on_before(env)
    @stack.reduce(env) do |e, current_middleware|
      if current_middleware.respond_to?(:before)
        e = current_middleware.before(e)
      end
      e
    end
  end

  def on_after(env)
    @stack.reduce(env) do |e, current_middleware|
      if current_middleware.respond_to?(:after)
        e = current_middleware.after(e)
      end
      e
    end
  end

  def on_error(env)
    @stack.reduce(env) do |e, current_middleware|
      if current_middleware.respond_to?(:error)
        e = current_middleware.error(e)
      end
      e
    end
  end

  def on_failure(env)
    @stack.reduce(env) do |e, current_middleware|
      if current_middleware.respond_to?(:failure)
        e = current_middleware.failure(e)
      end
      e
    end
  end
end
