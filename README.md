# Rhod

A High Avalibility framework for Ruby, inspired by [Hystrix](https://github.com/Netflix/Hystrix)

Rhod helps you maintain a highly avalible service when your code has to interact with other services. Often, we find ourselves writing code to keep our applications running in the event of failure in downstream serivces. Rhod helps you do this by providing you with a framework for managing failures, and delays.

Rhod comes with sane defaults but allows you to fully customize how your application reacts when it can't reach a service it needs. These defaults include:

  - Execute

## Installation

Add this line to your application's Gemfile:

    gem 'rhod'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rhod

## Usage

Rhod has a very simple API. Design your application as you would normally, then enclose network accessing portions of your code with


    Rhod.execute do
      ...
    end




## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create new Pull Request
