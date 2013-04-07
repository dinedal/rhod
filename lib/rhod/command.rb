class Rhod::Command

  EXCEPTIONS = [Exception, StandardError]

  def initialize(*args, &block)
    opts = args[-1].kind_of?(Hash) ? args.pop : {}
    @args = args
    @args ||= []

    @request = block

    @retries = opts[:retries]
    @retries ||= 0
    @attempts = 0

    @backoffs = Rhod::Backoffs.backoff_sugar_to_enumerator(opts[:backoffs])
    @backoffs ||= Rhod::Backoffs.default

    @fallback = opts[:fallback]
  end

  ### Class methods

  def self.execute(*args, &block)
    this = self.new(*args, &block)
    this.execute
  end

  ### Instance methods

  def execute
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

end
