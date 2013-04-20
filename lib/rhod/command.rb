class Rhod::Command

  EXCEPTIONS = [Exception, StandardError]

  @@pools = {}

  def initialize(*args, &block)
    opts = args[-1].kind_of?(Hash) ? args.pop : {}
    @args = args
    @args ||= []

    @request = block

    @retries = opts[:retries]
    @retries ||= Rhod.defaults[:retries]
    @attempts = 0

    @backoffs = Rhod::Backoffs.backoff_sugar_to_enumerator(opts[:backoffs])
    @backoffs ||= Rhod.defaults[:backoffs]

    @fallback = opts[:fallback]
    @fallback ||= Rhod.defaults[:fallback]

    @is_pooled = opts[:pool] ? true : false
    if @is_pooled
      @pool_name = opts[:pool][:name]

      @pool_size = opts[:pool][:size]
      @pool_size ||= 3

      @pool_timeout = opts[:pool][:timeout]
      @pool_timeout ||= 5
    end
  end

  ### Class methods

  def self.execute(*args, &block)
    this = self.new(*args, &block)
    this.execute
  end

  ### Instance methods

  def execute
    if @is_pooled
      if @pool_name
        pool = @@pools[@pool_name]
      else
        pool = @@pools[@pool_name = invoking_method]
      end
    end

    begin
      @request.call(*@args)
    rescue *EXCEPTIONS
      @attempts += 1
      if @attempts <= @retries
        sleep(@backoffs.next)
        retry
      else
        return @fallback.call(*@args) if @fallback
        raise
      end
    end
  end

  private

  def invoking_method
    # Ruby 1.9 support
    if !defined?(caller_locations)
      caller[0]
    else
      caller_locations(1,1).first
    end
  end

end
