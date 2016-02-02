# Agnostic Backend

`agnostic_backend` is a gem that provides indexing and searching
capabililities to Ruby objects by supplying two modules: `Indexable`
and `Queryable`. `Indexable` provides indexing functionality by
specifying a way to define which attributes of an object should be
included in the document to be indexed to a remote backend
store. `Queryable` provides search and retrieval functionality by
specifying a generic query language that seamlessly maps to specific
backend languages.

Although the motivation and use case for the gem relates to
`ActiveRecord` models, no assumption is made as to the classes to
which `Indexable` and `Queryable` are included in order to maximize
the flexibility of clients with respect to the use cases they need to
address.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'agnostic_backend'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install agnostic_backend

## Requirements

`agnostic_backend` requires a ruby version `>=2.1.0` due to the use of
mandatory keyword arguments in method definitions.

## Usage

### Indexable

### Queryable

## Tests

The gem's test suite runs by executing:

    $ bundle exec rspec spec

This will also generate a test coverage report in `coverage/index.html` for inspection.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/agnostic_backend. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
