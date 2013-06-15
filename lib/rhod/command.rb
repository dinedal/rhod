class Rhod::Command

  EXCEPTIONS = [Exception, StandardError]

  def initialize(*args, &block)
    opts            = args[-1].kind_of?(Hash) ? args.pop : {}
    @args           = args || []

    @request        = block

    @retries        = opts[:retries] || 0
    @attempts       = 0

    @logger         = opts[:logger]

    @backoffs       = Rhod::Backoffs.backoff_sugar_to_enumerator(opts[:backoffs])
    @backoffs     ||= Rhod::Backoffs::Logarithmic.new(1.3)

    @fallback       = opts[:fallback]

    @pool           = opts[:pool]

    @exceptions     = opts[:exceptions] || EXCEPTIONS

    @profile_name   = opts[:profile_name]
  end

  ### Class methods

  def self.execute(*args, &block)
    this = self.new(*args, &block)
    this.execute
  end

  ### Instance methods

  def execute
    begin
      if @pool
        @pool.with do |conn|
          @args = [conn].concat(@args)

          @request.call(*@args)
        end
      else
        @request.call(*@args)
      end
    rescue *@exceptions => e
      @attempts += 1
      @next_attempt = @backoffs.next
      if @attempts <= @retries
        @logger.warn("Rhod - Caught an exception: #{e.message}.  Attempt #{@attempts} in #{sprintf("%.2f", @next_attempt)} secs") if @logger && @logger.respond_to?(:warn)
        sleep(@next_attempt)
        retry
      else
        return @fallback.call(*@args) if @fallback
        raise
      end
    end
  end
end
