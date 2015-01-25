# Eldr::Responders [![Build Status](https://travis-ci.org/eldr-rb/eldr-responders.svg)](https://travis-ci.org/eldr-rb/eldr-responders) [![Code Climate](https://codeclimate.com/github/eldr-rb/eldr-responders/badges/gpa.svg)](https://codeclimate.com/github/eldr-rb/eldr-responders) [![Coverage Status](https://coveralls.io/repos/eldr-rb/eldr-responders/badge.svg?branch=master)](https://coveralls.io/r/eldr-rb/eldr-responders?branch=master) [![Dependency Status](https://gemnasium.com/eldr-rb/eldr-responders.svg)](https://gemnasium.com/eldr-rb/eldr-responders) [![Inline docs](https://inch-ci.org/github/eldr-rb/eldr-responders.svg?branch=master)](http://inch-ci.org/github/eldr-rb/eldr-responders) [![Gratipay](https://img.shields.io/gratipay/k2052.svg)](https://www.gratipay.com/k2052)

Rail's style responder helpers for [Eldr](https://github.com/eldr-rb/eldr)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eldr-responders'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eldr-responders

## Usage

```ruby
class App < Eldr::App
  get '/' do
    respond(@user)
  end
end
```
See [examples/app.ru](https://github.com/eldr-rb/eldr-responders/tree/master/examples/app.ru) for an example app.

## Contributing

1. Fork. it
2. Create. your feature branch (git checkout -b cat-evolver)
3. Commit. your changes (git commit -am 'Add Cat Evolution')
4. Test. your changes (always be testing)
5. Push. to the branch (git push origin cat-evolver)
6. Pull. Request. (for extra points include funny gif and or pun in comments)

To remember this you can use the easy to remember and totally not tongue-in-check initialism: FCCTPP.

I don't want any of these steps to scare you off. If you don't know how to do something or are struggle getting it to work feel free to create a pull request or issue anyway. I'll be happy to help you get your contributions up to code and into the repo!

## License

Licensed under MIT by K-2052.
