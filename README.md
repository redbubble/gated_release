# GatedRelease

This gem allows you to easily manage split code paths in your application without redeploys.

## Installation

### Gem

Add this line to your application's Gemfile:

```ruby
gem 'gated_release', '0.1.0' # see semver.org
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
GatedRelease::Gate.get('gate-name').run(
  open: -> { code_to_run_for_open_gate },
  closed: -> { code_to_run_for_closed_gate }
)
```

```ruby
# Close the gate on any error from the open code path
GatedRelease::Gate.get('gate-name').run(
  open: -> { code_to_run_for_open_gate },
  closed: -> { code_to_run_for_closed_gate },
  close_on_error: true
)
```

To open the gate:
```ruby
GatedRelease::Gate.get('gate-name').open!
```

To close the gate
```ruby
GatedRelease::Gate.get('gate-name').close!
```

To put the gate into a limited state, and allow a set number of code executions to go through the open gate before closing.
```ruby
GatedRelease::Gate.get('gate-name').limit!.allow_more!(10)
```

To put the gate into 'percentage' state, where a set percentage of code executions will go throught he open gate.
```ruby
GatedRelease::Gate.get('gate-name').percentage!(10)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/redbubble/gated_release. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

