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

  def on(event, env)
    @stack.reduce(env) do |e, current_middleware|
      if current_middleware.respond_to?(:on)
        e = current_middleware.on(event, e)
      end
      e
    end
  end

end
