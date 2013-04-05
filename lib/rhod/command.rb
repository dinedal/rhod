class Rhod::Command

  EXCEPTIONS = [Exception, StandardError]

  def initialize(*args, &block)
    opts = args[-1].kind_of?(Hash) ? args.pop : {}
    @request = block
    @args = args
    @args ||= []

    @retries = opts[:retries]
    @retries ||= 0
    @attempts = 0

    @backoffs = opts[:backoffs]
    @backoffs ||= Rhod::Backoffs.default
  end

  ### Class methods

  def self.execute(opts={}, &block)
    this = self.new(opts, &block)
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
        raise
      end
    end
  end

end
