# Rhod

A Lightweight High Avalibility framework for Ruby, inspired by [Hystrix](https://github.com/Netflix/Hystrix)

> Korben Dallas: You guard this with your life, or you're gonna look like this guy here! You green?
>
> DJ Ruby Rhod: G-green.
>
> Korben Dallas: Super green?
>
> DJ Ruby Rhod: Super green.

Rhod helps you handle failures gracefully, even during a firefight. When your code has to interact with other services, it also means writing code to keep it running in the event of failure. Failures can include exceptions, timeouts, downed hosts, and any number of issues that are caused by events outside of your application.

Rhod allows you to fully customize how your application reacts when it can't reach a service it needs. but by default it is configured for a 'fail fast' scenario. With some configuration, Rhod can support the following failure scenarios and variations on them:

  - Fail Fast
  - Retry N times before Fail
  - Retry N times with progressive backoffs before Fail
  - Fail Silent
  - Fail w/ Fallback
  - Primary / Secondary ("hot spare") switch over

## Installation

Rhod requires Ruby 1.9.2 or greater.

Add this line to your application's Gemfile:

```ruby
gem 'rhod'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rhod

## Configuration

To configure Rhod's defaults, change any of the keys in `Rhod.defaults`

```ruby
Rhod.defaults
=> {:retries=>0,
 :backoffs=>#<Enumerator: ...>,
 :fallback=>nil}
```

## Usage

Rhod has a very simple API. Design your application as you would normally, then enclose network accessing portions of your code with:

```ruby
Rhod.execute do
  ...
end
```

This implements the "Fail Fast" scenario by default.

Example, open a remote reasource, fail immediately if it fails:

```ruby
require 'open-uri'
require 'rhod'

Rhod.execute { open("http://google.com").read }
```

## An Important note about arguments:

Do not reach into the outer scope when using Rhod, instead you can pass arguments into your block like so:

```ruby
address = "http://google.com"

Rhod.execute(address) do |url|
   open(url).read
end
```

If you need to pass options to Rhod, pass them as the last argument:

```ruby
# Works the same as the above, with but with retires.
address = "http://google.com"

Rhod.execute(address, :retries => 5) do |url|
   open(url).read
end
```

### Retries with and without backoffs

#### Idempotence Caution

Code within a `Rhod::Command` block with reties in use must be _idempotent_, i.e., safe to run multiple times.

Rhod supports retying up to N times. By default it uses a logarithmic backoff:

```ruby
Rhod::Backoffs.default.take(5)
# [0.7570232465074598, 2.403267722339301, 3.444932048942182, 4.208673319629471, 4.811984719351674]
```

Rhod also comes with exponential and constant (always the same value) backoffs. You can also supply any Enumerator that produces a series of numbers. See `lib/rhod/backoffs.rb` for examples.

Example, open a remote reasource, fail once it has failed 10 times, with the default (logarithmic) backoff:

```ruby
require 'open-uri'
require 'rhod'

Rhod::Command.execute(:retries => 10) { open("http://google.com").read }
```

Example, open a remote reasource, fail once it has failed 10 times, waiting 0.2 seconds between attempts:

```ruby
require 'open-uri'
require 'rhod'

    Rhod.execute(:retries => 10, :backoffs => 0.2) do
      open("http://google.com").read
    end
```

Example, open a remote reasource, fail once it has failed 10 times, with an exponetially growing wait time between attempts:

```ruby
require 'open-uri'
require 'rhod'

Rhod.execute(:retries => 10, :backoffs => :^) do
  open("http://google.com").read
end
```

Example, open a remote reasource, fail once it has failed 10 times, with no waiting between attempts:

```ruby
require 'open-uri'
require 'rhod'

Rhod.execute(:retries => 10, :backoffs => 0) do
  open("http://google.com").read
end
```

Example, open a remote reasource, fail once it has failed 10 times, with a random wait between 1 and 5 seconds on each attempt

```ruby
require 'open-uri'
require 'rhod'

Rhod.execute(:retries => 10, :backoffs => 'r1..5') do
  open("http://google.com").read
end
```


### Fail Silent

In the event of a failure, Rhod falls back to a `fallback`. The most basic case is to fall back to a constant value.

Example, open a remote reasource, if it fails return them empty string.

```ruby
require 'open-uri'
require 'rhod'

Rhod.execute(:fallback => -> {""}) do
  open("http://google.com").read
end
```

### Fail w/ Fallback

If there is another network call that can be used to fetch the reasource, it's possible to use another `Rhod::Command` once a failure has occurred.

```ruby
require 'open-uri'
require 'rhod'

search_engine_fallback = Rhod::Command.new(
  :fallback => -> {""} # couldn't get anything
) do
  open("https://yahoo.com").read
end

Rhod.execute(:fallback => -> { search_engine_fallback.execute }) do
  open("http://google.com").read
end
```

### Primary / Secondary ("Hot Spare") switch over

Sometimes the fallback is just a part of normal operation. Just code in the state of which back end to access.

```ruby
require 'open-uri'
require 'rhod'

class SearchEngineHTML
  attr_accessor :secondary

  def fetch
    url = !@secondary ? "http://google.com" : "https://yahoo.com"

    Rhod.execute(url, :fallback => Proc.new { @secondary = !@secondary; fetch }) do |url|
      open(url).read
    end
  end
end

search_engine_html = SearchEngineHTML.new

search_engine_html.fetch
```

## Connection Pools

Sometimes you're connecting to a remote reasource using a driver that doesn't support connection pooling, which will limit the amount of strain your application puts on that reasource, and allow for reuse of existing connections instead of increasing overhead by reconnecting each time. Connection Pool support in Rhod is provided by the [connection_pool](https://github.com/mperham/connection_pool) gem.

```ruby
require 'rhod'
require 'redis'
require 'connection_pool'

Rhod.connection_pools[:redis] = ConnectionPool.new(size:3, timeout:5) { Redis.new }

Rhod.execute(:pool => :redis) {|redis| redis.set("foo", "bar") }
```

The connection is always the first argument passed into the block, the other arguments are passed in their original order after.

```ruby
key   = "foo"
value = "bar"
Rhod.execute(key, value, :pool => :redis) {|redis, k, v| redis.set(k, v) }
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Make your changes and add tests, verify they pass with (`bundle exec rake test`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin feature/my-new-feature`)
6. Create new Pull Request
