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
Rhod.with_default do
  ...
end
```

This implements the [Fail Fast](https://github.com/dinedal/rhod/wiki/Fail-Fast) scenario by default.

Rhod allows you to fully customize how your application reacts when it can't reach a service it needs. but by default it is configured for a 'fail fast' scenario. With some configuration, Rhod can support the following failure scenarios and variations on them:

  - [Fail Fast](https://github.com/dinedal/rhod/wiki/Fail-Fast)
  - [Retry N times before Fail](https://github.com/dinedal/rhod/wiki/Retry-N-times-before-Fail)
  - [Retry N times with progressive backoffs before Fail](https://github.com/dinedal/rhod/wiki/Retry-N-times-with-progressive-backoffs-before-Fail)
  - [Fail Silent](https://github.com/dinedal/rhod/wiki/Fail-Silent)
  - [Fail w/ Fallback](https://github.com/dinedal/rhod/wiki/Fail-with-Fallback)
  - [Primary / Secondary ("hot spare") switch over](https://github.com/dinedal/rhod/wiki/Primary-Secondary-Switchover)

Check the [wiki](https://github.com/dinedal/rhod/wiki/) for more documentation.

## Upgrading from v0.0.x to v0.1.x

The only breaking API change is that backoffs have changed in their creation, dropping `Enumerator` in favor of a simple threadsafe class. Please switch any custom backoff code subclass `Rhod::Backoffs::Backoff`.

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

### Creating or Editing a New Profile
To configure Rhod's defaults, just overwrite the default profile with any changes you'd like to make. If you're on Rails, a good place for your profiles is `config/initializers/rhod.rb`

```ruby
Rhod.create_profile(:default, retries: 10)
# => {:retries=>10,
#  :backoffs=>#<Rhod::Backoffs::Logarithmic:0x007f89afaeb4c0 @state=1.3>,
#  :fallback=>nil,
#  :pool=>
#   #<ConnectionPool:0x007f89afaeb470
#    @available=
#     #<ConnectionPool::TimedStack:0x007f89afaeb3d0
#      @mutex=#<Mutex:0x007f89afaeb358>,
#      @que=[nil],
#      @resource=
#       #<ConditionVariable:0x007f89afaeb330
#        @waiters={},
#        @waiters_mutex=#<Mutex:0x007f89afaeb2e0>>>,
#    @key=:"current-70114667354600",
#    @size=1,
#    @timeout=0>,
#  :exceptions=>[Exception, StandardError]}
```

Creating a new profile will copy from the default profile any unspecified options:

```ruby
Rhod.create_profile(:redis,
  retries: 10,
  backoffs: :^,
  pool: ConnectionPool.new(size: 3, timeout: 10) { Redis.new },
  exceptions: [Redis::BaseError],
  logger: Logger.new(STDOUT)
  )

Rhod.with_redis("1") {|r, a| r.set('test',a)}
# => "OK"
Rhod.with_redis {|r| r.get('test')}
# => "1"
```

## Idempotence Caution

Code within a `Rhod::Command` block with reties in use must be _idempotent_, i.e., safe to run multiple times.

## Passing arguments

Code within a `Rhod::Command` should avoid leaking memory and/or scope by having arguments passed to it:

## Logging

Rhod can optionally log all failures, very useful for debugging. Just set a logger in a profile and they will be logged at the level `:warn`

```ruby
Rhod.create_profile(:verbose, logger: Logger.new(STDOUT))
```

### Good use of argument passing:

```ruby
Rhod.with_default("http://google.com") {|url| open(url).read}
```

## Connection Pools

Sometimes you're connecting to a remote reasource using a driver that doesn't support connection pooling, which will limit the amount of strain your application puts on that reasource, and allow for reuse of existing connections instead of increasing overhead by reconnecting each time. Connection Pool support in Rhod is provided by the [connection_pool](https://github.com/mperham/connection_pool) gem.

```ruby
require 'rhod'
require 'redis'
require 'connection_pool'

Rhod.create_profile(:redis,
  pool: ConnectionPool.new(size: 3, timeout: 5) { Redis.new }
  )

Rhod.with_redis {|redis| redis.set("foo", "bar") }
# => "OK"
```

The connection is always the first argument passed into the block, the other arguments are passed in their original order after.

```ruby
key   = "foo"
value = "bar"
Rhod.with_redis(key, value) {|redis, k, v| redis.set(k, v) }
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Make your changes and add tests, verify they pass with (`bundle exec rake test`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin feature/my-new-feature`)
6. Create new Pull Request
