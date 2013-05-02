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
    @backoffs ||= Rhod::Backoffs::Logarithmic.new(1.3)

    @fallback = opts[:fallback]

    @pool = opts[:pool]
    @pool ||= ConnectionPool.new(size: 1, timeout: 0) { nil }

    @exceptions = opts[:exceptions]
    @exceptions ||= EXCEPTIONS
  end

  ### Class methods

  def self.execute(*args, &block)
    this = self.new(*args, &block)
    this.execute
  end

  ### Instance methods

  def execute
    begin
      @pool.with do |conn|
        @args = [conn].concat(@args)
        @args[0] == nil ? @args.shift : nil

        @request.call(*@args)
      end
    rescue *@exceptions
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
