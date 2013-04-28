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

# Is it any good?

[Yes](https://news.ycombinator.com/item?id=3067434)

## Usage

Rhod has a very simple API. Design your application as you would normally, then enclose network accessing portions of your code with:

```ruby
Rhod.execute do
  ...
end
```

This implements the "Fail Fast" scenario by default.

Rhod allows you to fully customize how your application reacts when it can't reach a service it needs. but by default it is configured for a 'fail fast' scenario. With some configuration, Rhod can support the following failure scenarios and variations on them:

  - [Fail Fast](https://github.com/dinedal/rhod/wiki/Fail-Fast)
  - [Retry N times before Fail](https://github.com/dinedal/rhod/wiki/Retry-N-times-before-Fail)
  - [Retry N times with progressive backoffs before Fail](Retry-N-times-with-progressive-backoffs-before-Fail)
  - [Fail Silent](https://github.com/dinedal/rhod/wiki/Fail-Silent)
  - [Fail w/ Fallback](https://github.com/dinedal/rhod/wiki/Fail-with-Fallback)
  - [Primary / Secondary ("hot spare") switch over](https://github.com/dinedal/rhod/wiki/Primary-Secondary-Switchover)

Check the wiki for more documentation.

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

## Idempotence Caution

Code within a `Rhod::Command` block with reties in use must be _idempotent_, i.e., safe to run multiple times.

## Passing arguments

Code within a `Rhod::Command` should avoid leaking memory and/or scope by having arguments passed to it:

## Controlling Retries Examples

Default Behavior: logarithmic backoff (0, 2, 3.2, 4, 4.6 secs before raising exception)
```ruby
Rhod.execute(retries: 5) {}
Rhod.execute(retries: 5, backoffs: 'l') {}
```

Exponential Backoff: (0,1,4,9,16 secs)
```ruby
Rhod.execute(retries: 5, backoffs: '^') {}
```

Constant backoff: (2, 2, 2, 2, 2 secs)
```ruby
Rhod.execute(retries: 5, backoffs: 2) {}
```

Random Backoffs (default [1..10]): (1,2,6,10,2 secs)
```ruby
Rhod.execute(retries: 5, backoffs: 'r') {}
Rhod.execute(retries: 5, backoffs: 1..10) {}
```

Custom Enumator Backoff (1,2,3,4,5 secs)
```ruby
Rhod.execute(retries: 5, backoffs: [1..5].each) {}
```

### Good use of argument passing:

```ruby
Rhod.execute("http://google.com") {|url| open(url).read}
```

You can still pass arguments to Rhod as the last argument passed to `Rhod.execute`

```ruby
# Attempt 5 times before failing
Rhod.execute("http://google.com", :retries => 5) {|url| open(url).read}
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
