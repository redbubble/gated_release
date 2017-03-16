# GatedRelease

This gem allows you to easily manage split code paths in your application without redeploys.

## Installation

### Gem

Add this line to your application's Gemfile:

```ruby
gem 'gated_release'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gated_release

### Setup

Generate and migrate the installation database migration

```
$ bundle exec rails generate gated_release:install
$ bundle exec rake db:migrate
```

## Usage

```ruby
GatedRelease.get('gate-name').run(
  open: -> { code_to_run_for_open_gate },
  closed: -> { code_to_run_for_closed_gate }
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/redbubble/gated_release. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

