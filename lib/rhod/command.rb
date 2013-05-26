class Rhod::Command

  EXCEPTIONS = [Exception, StandardError]

  def initialize(*args, &block)
    opts            = args[-1].kind_of?(Hash) ? args.pop : {}
    @args           = args
    @args         ||= []

    @request        = block

    @retries        = opts[:retries]
    @retries      ||= 5
    @attempts       = 0
    
    @logger         = opts[:logger] || Logger.new(STDOUT)
    @enable_logging = opts[:enable_logging].nil? ? true : opts[:enable_logging]

    @backoffs       = Rhod::Backoffs.backoff_sugar_to_enumerator(opts[:backoffs])
    @backoffs     ||= Rhod::Backoffs::Logarithmic.new(1.3)

    @fallback       = opts[:fallback]

    @pool           = opts[:pool]

    @exceptions     = opts[:exceptions]
    @exceptions    ||= EXCEPTIONS
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
        @logger.warn("Exception encountered in Rhod Block: #{e.message}.  Attempt #{@attempts} in #{sprintf("%.2f", @next_attempt)} secs") if @logger.respond_to?(:warn) && @enable_logging
        sleep(@next_attempt)
        retry
      else
        return @fallback.call(*@args) if @fallback
        raise
      end
    end
  end
end
