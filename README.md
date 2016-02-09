# Agnostic Backend

`agnostic_backend` is a gem that provides indexing and searching
capabililities to Ruby objects by supplying two modules: `Indexable`
and `Queryable`. `Indexable` provides indexing functionality by
specifying a way to define which attributes of an object should be
included in a document to be indexed to a remote backend
store. `Queryable` provides search and retrieval functionality by
specifying a generic query language that seamlessly maps to specific
backend languages.

In addition to these two modules, `agnostic_backend` supplies
additional classes (`Indexer` and `Index`) to support the
configuration and functionality of remote backends (such as
elasticsearch, AWS Cloudsearch etc.).

Although the motivation and use case for the gem relates to
`ActiveRecord` models, no assumption is made as to the classes to
which `Indexable` and `Queryable` are included. The objective is to
maximize the flexibility of clients with respect to the use cases they
need to address.

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
mandatory keyword arguments in method definitions. Check the `Gemfile`
for more info on dependencies.

## Usage

### Indexable

Use the following to enable indexing functionality to a class:

```ruby
class Task < ActiveRecord::Base
  include AgnosticBackend::Indexable

  belongs_to :workflow, class_name: 'Workflow'

  define_index_fields do
    integer :id
    date :last_assigned_at, value: :assigned_at, label: 'Last Assigned At'
    string :type, value: proc { task_category.name }
    struct :workflow, from: Workflow
  end
end
```

In the example above, `Task` defines a few attributes to be included
in the document to be indexed along with their types (`integer`,
`date` and so on), values (symbols or `procs`s) and custom attributes
(`label`).

The specification of types therein opens up the possibility of
assembling the document's schema at runtime. This can be useful for
configuring a remote backend without having to manually specify the
schema. In our example, the `Task`'s schema (as defined by its index
fields) can be retrieved using:

```ruby
> Task.schema
{
  :id => :integer,
  :last_assigned_at => :date,
  :type => :string,
  :workflow => {
    // the workflow's schema is nested here
  }
}
```

As can be seen in the above example, `Indexable` supports nested
documents. In this case, the document that corresponds to the
`Workflow` class (to which `Task` belongs) will be included in the
`Task`'s schema, as well as in the generated document:

```ruby
> task.generate_document
{
  :id => 10,
  :last_assigned_at => '2015-10-01T10:22:33Z',
  :type => 'FirstTask',
  :workflow => {
    // the Workflow instance's contents (document) are nested here
  }
}
```

More information about the use of `Indexable` can be found in
[this document](src/master/doc/indexable.md).

### Queryable

Queries are built and executed against a remote backend. Assuming the
same `Task` class as before:

```ruby
class Task < ActiveRecord::Base
  include AgnosticBackend::Indexable
  include AgnosticBackend::Queryable

  belongs_to :workflow, class_name: 'Workflow'

  define_index_fields do
    integer :id
    date :last_assigned_at, value: :assigned_at, label: 'Last Assigned At'
    string :type, value: proc { task_category.name }
    struct :workflow
  end
end
```

Queries can be composed as in the following example:

```ruby
query_builder = Task.query_builder
criteria_builder = query_builder.criteria_builder

# Let's build the query:
# last_assigned_at < '2015-10-10' OR type = 'FirstTask'
criteria = criteria_builder.or(
             criteria_builder.lt('last_assigned_at', '2015-10-10T00:00:00Z'),
             criteria_builder.eq('type', 'FirstTask'))

# Setup the where clause
query_builder.where(criteria)

# Let's put some more constraints
query_builder.order('id', :asc)
query_builder.limit(10)

# compile the query
query = query_builder.build

# and run it!
result = query.execute
```

The `result` is an instance of `Queryable::ResultSet` that gives
access to the results returned by the backend.

For more information about `Queryable` check out
[this document](src/master/doc/queryable.md).


### Backend Implementation

New backends can be implemented by subclassing `Index` and `Indexer`.

`Index` is responsible for representing a remote backend in which a
particular repo (index/table) for a specific model exists. This
implies that `Index` is responsible for any communications that occur
between the client and the backend, as well as any
initialization/configuration (credentials etc.) tasks. `Index` is also
the context in which a query is built and executed.

`Indexer` is responsible for document handling, i.e. publishing to and
deleting documents from the remote backend. These processes are broken
down to steps, including pre-processing, transformations, and
conversions to other formats (xml, json). This is reflected in the
default implementation of `Indexer#put` (that sends a document to the
remote backend) which actually does (among other things):

```ruby
    publish(transform(prepare(document)))
```

For example, a remote backend may not support the indexing of
documents with `nil` values. As part of the pre-processing step
(`#prepare`), the implementor of a specific backend might choose to
exclude `nil` values from the document before forwarding it down the
chain.


## Tests

The gem's test suite runs by executing:

    $ bundle exec rspec spec

This will also generate a test coverage report in `coverage/index.html` for inspection.

## Development

After checking out the repo, run `bin/setup` to install
dependencies. Then, run `rake spec` to run the tests. You can also run
`bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake
install`. To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release`, which will
create a git tag for the version, push git commits and tags, and push
the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/[USERNAME]/agnostic_backend. This project is
intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the
[Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
