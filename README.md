# Rhod

A Lightweight High Avalibility framework for Ruby, inspired by [Hystrix](https://github.com/Netflix/Hystrix)

> Korben Dallas: You guard this with your life, or you're gonna look like this guy here! You green?
> DJ Ruby Rhod: G-green.
> Korben Dallas: Super green?
> DJ Ruby Rhod: Super green.

Rhod helps you maintain a highly avalible service when your code has to interact with other services. Often, we find ourselves writing code to keep our applications running in the event of failure in downstream serivces. Rhod helps you do this by providing you with a framework for managing failures.

Rhod allows you to fully customize how your application reacts when it can't reach a service it needs. but by default it is configured for a 'fail fast' scenario. With some configuration, Rhod can support the following failure scenarios and variations on them:

  - Fail Fast
  - Retry N times before Fail
  - Retry N times with progressive backoffs before Fail
  - Fail Silent
  - Fail w/ Fallback
  - Primary / Secondary ("hot spare") switch over


## Installation

Add this line to your application's Gemfile:

    gem 'rhod'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rhod

## Usage

Rhod has a very simple API. Design your application as you would normally, then enclose network accessing portions of your code with:

    Rhod::Command.execute do
      ...
    end

This implements the "Fail Fast" scenario by default.

Example, open a remote reasource, fail immediately if it fails:

    require 'open-uri'

    Rhod::Command.execute { open("http://google.com").read }

### Retries with and without backoffs

Rhod supports retying up to N times. By default it uses a logarithmic backoff:

    Rhod::Backoffs.default.take(5)
    # [0.7570232465074598, 2.403267722339301, 3.444932048942182, 4.208673319629471, 4.811984719351674]

Rhod also comes with exponential and constant (always the same value) backoffs. You can also supply any Enumerator that produces a series of numbers. See `lib/rhod/backoffs.rb` for examples.

Example, open a remote reasource, fail once it has failed 10 times, with the default (logarithmic) backoff:

    require 'open-uri'

    Rhod::Command.execute(:retries => 10) { open("http://google.com").read }

Example, open a remote reasource, fail once it has failed 10 times, waiting 0.2 seconds between attempts:

    require 'open-uri'

    Rhod::Command.execute(:retries => 10, :backoffs => Rhod::Backoffs.constant_backoff(0.2)) do
      open("http://google.com").read
    end

Example, open a remote reasource, fail once it has failed 10 times, with an exponetially growing wait time between attempts:

    require 'open-uri'

    Rhod::Command.execute(:retries => 10, :backoffs => Rhod::Backoffs.expoential_backoffs) do
      open("http://google.com").read
    end

Example, open a remote reasource, fail once it has failed 10 times, with waiting between attempts:

    require 'open-uri'

    Rhod::Command.execute(:retries => 10, :backoffs => Rhod::Backoffs.constant_backoff(0)) do
      open("http://google.com").read
    end


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create new Pull Request
