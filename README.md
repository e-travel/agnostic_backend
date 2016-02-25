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
which `Indexable` and `Queryable` can be included. The objective is to
maximize the flexibility of clients with respect to the use cases they
need to address.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'agnostic_backend'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install agnostic_backend

## Requirements

`agnostic_backend` requires a ruby version `>=2.1.0` due to the use of
mandatory keyword arguments in method definitions. Check the `Gemfile`
for more info on dependencies.

## Usage

For the purposes of this document, we will focus on `ActiveRecord`
examples. Let's assume we have two AR models, `Task` and `Workflow`,
connected using an one-to-many relationship (i.e. a `Workflow` has
many `Task`s) as follows:

```ruby
class Task < ActiveRecord::Base
  include AgnosticBackend::Indexable

  belongs_to :workflow, class_name: 'Workflow'
end

class Workflow < ActiveRecord::Base
  include AgnosticBackend::Indexable

  has_many :tasks, class_name: 'Task'
end
```

Let's assume also that we have a remote store to which we would like
to index documents related to `Task`s and from which we would like to
retrieve these documents by performing queries based on the document
fields.

### Indexable

In order to index individual tasks, we need to specify three things:

- what should the document contain (we'll use
  `Indexable::ClassMethods#define_index_fields`)
- who should be notified when the object needs to be indexed (we'll
  use `Indexable::ClassMethods#define_index_notifier`)
- when should the above notification(s) occur (we'll use `ActiveRecord`'s
  `after_commit` callback)

Let's see that in action:

```ruby
class Task < ActiveRecord::Base
  # let's make our class Indexable
  include AgnosticBackend::Indexable

  belongs_to :workflow, class_name: 'Workflow'

  # define what should the document contain
  define_index_fields do
    integer :id
    date :last_assigned_at, value: :assigned_at, label: 'Last Assigned At'
    string :type, value: proc { task_category.name }, label: 'Task Type'
    struct :workflow, from: Workflow
  end

  # define who should be notified when this object needs to be indexed
  define_index_notifier { self }

  # define when should the above notifications occur
  # we'll use Indexable's trigger_index_notification instance method
  after_commit :trigger_index_notification
end

class Workflow < ActiveRecord::Base
  # let's make our class Indexable
  include AgnosticBackend::Indexable

  has_many :tasks, class_name: 'Task'

  # define what should the document contain and who is the owner
  # Note that the contents are part of the document
  # created by a `Task` instance
  define_index_fields(owner: Task) do
    integer :id
    date :creation_date, value: :created_at, label: 'Creation Date'
  end

  # define who should be notified when this object needs to be indexed
  define_index_notifier(target: Task) { tasks }

  # define when should the above notifications occur
  # we'll use Indexable's trigger_index_notification instance method
  after_commit :trigger_index_notification
end
```

The above definitions achieve the following things:

- when a task is created/updated, a document is generated and sent to
  the remote backend for indexing
- this document includes a section `workflow` that contains the
  associated `Worflow`'s document (see `struct` entry in `Task`'s
  `define_index_fields`)
- when a workflow is created/updated, all its associated tasks are
  notified in order to index themselves (see `define_index_notifiers`
  in both classes)

Now that we've defined our models and configured their indexing, let's
play a bit more:

```ruby
# First, let's configure our remote backend
# we'll use AWS Cloudsearch as an example
AgnosticBackend::Indexable::Config.configure_index(
  Task,
  AgnosticBackend::Cloudsearch::Index,
  region: "the_region",
  domain_name: "the_domain_name",
  document_endpoint: "the_document_endpoint",
  search_endpoint: "the_search_endpoint",
  access_key_id: "the_access_key_id",
  secret_access_key: "the_secret_access_key"
)

# Let's create a Workflow and persist it
> workflow = Workflow.create(...)
# Let's add a couple of tasks
> 2.times { workflow << Task.create(...) }

# at this point, our two tasks have already been indexed
# due to the after_commit callbacks

# let's grab the first task
> task = workflow.tasks.first

# let's generate and inspect a document for this task
> task.generate_document
{:id => 10,
 :last_assigned_at => '2015-12-30T12:34:55',
 :type => 'SomeTask',
 # includes the workflow contents
 # through the struct relationship in Task's define_index_fields
 :workflow => {
   :id => 4,
   :creation_date => '2015-12-30T12:34:53'
 }
}

# we can index it again (synchronously)
> task.put_to_index

# the following achieves the same thing by default
# but Indexable's method can be overriden in order
# to implement custom functionality (e.g. asynchronous indexing)
> task.index_object

# hey, we can get the document schema too!
> Task.schema
{:id => :integer,
 :last_assigned_at => :date,
 :type => :string,
 :workflow => {
   :id => :integer,
   :creation_date => :date
 }
}

# and any custom property that we supplied in define_index_fields
# in this case :label
> Task.schema {|field_type| field_type.get_option(:label)}
{:id => nil,
 :last_assigned_at => "Last Assigned At",
 :type => "Task Type",
 :workflow => {
   :id => nil,
   :creation_date => "Creation Date"
 }
}
```

More information about the use of `Indexable` can be found in
[this document](src/master/doc/indexable.md).

### Queryable

Queries are built and executed against a remote backend. Assuming the
same `Task` class as before:

```ruby
> query_builder = Task.query_builder
> criteria_builder = query_builder.criteria_builder

# Let's build the query:
# last_assigned_at < '2015-10-10' OR type = 'FirstTask'
> criteria = criteria_builder.or(
               criteria_builder.lt('last_assigned_at', '2015-10-10T00:00:00Z'),
               criteria_builder.eq('type', 'FirstTask'))

# Setup the where clause
> query_builder.where(criteria)

# Let's put some more constraints
> query_builder.order('id', :asc)
> query_builder.limit(10)

# compile the query
> query = query_builder.build

# and run it!
results = query.execute

# results is a Queryable::ResultSet instance that gives
# access to the backend results; these follow the document's schema
> results.map {|result| result['workflow']['creation_date'] }
```

For more information about `Queryable` check out
[this document](src/master/doc/queryable.md).


### Backends

Currently, the gem includes one concrete backend implementation that
talks to [AWS Cloudsearch](https://aws.amazon.com/cloudsearch/). New
backends can be implemented by subclassing `AgnosticBackend::Index`
and `AgnosticBackend::Indexer` (more on that later).

#### The Index

`AgnosticBackend::Index` is responsible for representing a particular
repo (aka index/table) in a remote backend for a specific model. This
implies that `Index` is responsible for any communications that occur
between the client and the backend, as well as any
initialization/configuration (credentials etc.) tasks. `Index` is also
the context in which a query is built and executed.

`AgnosticBackend::Indexable` exposes the `Config` class in order to
facilitate the initialization/configuration of an index at
runtime. For example, the initialization/configuration of the
Cloudsearch index that corresponds to the indexing of `Task`s can be
achieved by:

```ruby
AgnosticBackend::Indexable::Config.configure_index(
  Task, # the class whose instances are indexed
  AgnosticBackend::Cloudsearch::Index, # the concrete Index class
  # and various parameters related to the specific backend (Cloudsearch)
  region: 'the_region',
  domain_name: 'the_domain_name',
  document_endpoint: 'the_document_endpoint',
  search_endpoint: 'the_search_endpoint',
  access_key_id: 'the_access_key_id',
  secret_access_key: 'the_secret_access_key'
)
```

The remote index's name should follow the convention used by
`Indexable` (see `Indexable::ClassMethods#index_name`) according to
which the remote index name is automatically determined given the
including class's name convention.

#### The Indexer

`AgnosticBackend::Indexer` is responsible for document handling,
i.e. publishing documents to and deleting documents from the remote
backend. These processes are broken down into discrete steps,
including pre-processing, transformations, and conversions to other
formats (xml, json). This is reflected in the default implementation
of `Indexer#put` (that sends a document to the remote backend) which
actually does (among other things):

```ruby
publish(transform(prepare(document)))
```

For example, a remote backend may not support the indexing of
documents with `nil` values. As part of the pre-processing step
(`#prepare`), the implementor of a specific backend might choose to
exclude `nil` values from the document before forwarding it down the
chain.

## Development

After checking out the repo, run `bundle exec bin/setup` or `bundle
install` to install dependencies. Then, run `bundle exec rake spec` or
`bundle exec rspec spec` to run the tests. This will also generate a
test coverage report in `coverage/index.html` for inspection. You can
also run `bin/console` for an interactive prompt that will allow you
to experiment.

To install this gem onto your local machine, run `bundle exec rake
install`. To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release`, which will
create a git tag for the version, push git commits and tags, and push
the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/e-travel/agnostic_backend. This project is intended
to be a safe, welcoming space for collaboration, and contributors are
expected to adhere to the
[Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
