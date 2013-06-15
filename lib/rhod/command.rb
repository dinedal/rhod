class Rhod::Command

  EXCEPTIONS = [Exception, StandardError]

  def initialize(*args, &block)
    opts            = args[-1].kind_of?(Hash) ? args.pop : {}
    @env = {
      :args           => args || [],
      :request        => block,
      :retries        => opts[:retries] || 0,
      :attempts       => 0,
      :logger         => opts[:logger],
      :backoffs       => Rhod::Backoffs.backoff_sugar_to_enumerator(opts[:backoffs]) || Rhod::Backoffs::Logarithmic.new(1.3),
      :fallback       => opts[:fallback],
      :pool           => opts[:pool],
      :exceptions     => opts[:exceptions] || EXCEPTIONS,
      :profile_name   => opts[:profile_name],
    }
  end

  ### Class methods

  def self.execute(*args, &block)
    this = self.new(*args, &block)
    this.execute
  end

  ### Instance methods

  def execute
    begin
      if @env[:pool]
        @env[:pool].with do |conn|
          @env[:args] = [conn].concat(@env[:args])

          @env[:request].call(*@env[:args])
        end
      else
        @env[:request].call(*@env[:args])
      end
    rescue *@env[:exceptions] => e
      @env[:attempts] += 1
      @env[:next_attempt] = @env[:backoffs].next
      if @env[:attempts] <= @env[:retries]
        @env[:logger].warn("Rhod - Caught an exception: #{e.message}.  Attempt #{@env[:attempts]} in #{sprintf("%.2f", @env[:next_attempt])} secs") if @env[:logger] && @env[:logger].respond_to?(:warn)
        sleep(@env[:next_attempt])
        retry
      else
        return @env[:fallback].call(*@env[:args]) if @env[:fallback]
        raise
      end
    end
  end
end
