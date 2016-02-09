# Indexable module Guide

Broadly speaking, the `Indexable` module provides classes with
functionality related to the following:

- define what should be indexed as a document (attributes, nested
  fields, types etc.)
- define how it should be indexed (when the object changes in some
  way)

In our examples below, we are working with `ActiveRecord` models, but
`AgnosticBackend` can be used with any object. Also, whenever we
mention the word "document" below, we take this to be a Ruby Hash.

## Document contents

Say we need to represent a workflow comprising a sequence of tasks
within a case, using a `Workflow` AR model and a `Task` AR model
connected by a one-to-many relationship, as follows:

```ruby
class Task < ActiveRecord::Base
  belongs_to :workflow, class_name: 'Workflow'
end

class Workflow < ActiveRecord::Base
  has_many :tasks, class_name: 'Task'
end
```

We can specify what to index in the `Task` model by including
`AgnosticBackend::Indexable` and using the `define_index_fields`
method as follows:

```ruby
class Task < ActiveRecord::Base
  include AgnosticBackend::Indexable
  belongs_to :workflow, class_name: 'Workflow'

  define_index_fields do
    integer :id
    date :last_assigned_at, value: :assigned_at
    string :type, value: proc { task_category.name }
  end
end
```

In this case, we specify that the document to be generated when the
time comes (more about that below) will include 3 fields: `id`,
`last_assigned_at` and `type`. Let's look at each one of them in more
detail. The document will contain a field with the key `id` and the
value that will be generated when the object receives the message
`:id` at document generation time. This means that in the simplest
possible case, the field's key is a method to which we expect the
object to respond. The document will also contain the
`last_assigned_at` key whose value will be determined by sending the
message `assigned_at` to the object. Finally, the document will also
contain the field `type` which in this case is a computed value that
will be determined at runtime at executing the specified `proc` in the
context of `self` (i.e. in the context of the class's instance).

## Nested documents

`Indexable` supports the specification of nested documents by using
the `struct` type as follows:

```ruby
class Task < ActiveRecord::Base
  include AgnosticBackend::Indexable
  belongs_to :workflow, class_name: 'Workflow'

  define_index_fields do
    integer :id
    date :last_assigned_at, value: :assigned_at
    string :type, value: proc { task_category.name }
    struct :workflow, from: Workflow
  end
end
```

As a result, the document will also contain a `workflow` field whose
value will be derived by requesting a document from the object's
`workflow` reference (which is a `Workflow` instance). In order to get
this to work, we need a corresponding definition in the `Workflow`
class as follows:

```
class Workflow < ActiveRecord::Base
  include AgnosticBackend::Indexable
  has_many :tasks, class_name: 'Task'

  define_index_fields(owner: Task) do
    integer :id
    date :created_at
    text_array :notes, value: proc { notes.map(&:body) }
  end
end
```

Notice the use of the `owner: Task` argument in
`define_index_fields`. This means that the document specified within
the block is to be used only when requested by the `Task`'s document
generation process. It also implies that we can specify multiple
document definitions in the same class for different owners. When the
owner is not specified, it is taken to be the class in which the
definition is written.

## Document Generation

Use the `Indexable#generate_document` method in order to obtain a hash
with the document's contents. For example, given a `Task` instance:

```ruby
> task.generate_document
{:id=>5, :last_assigned_at=>2016-02-09 19:45:00 UTC, ...,
 :workflow=>{:id=>6, ...}}
```

The document includes all fields specified in `Task` including the
nested hash retrieved from `Workflow`.

## When should a document be indexed

`Indexable` does not specify when and in what way a document should be
indexed. Instead, this decision is up to the client. The objective is
to achieve the maximum flexibility with regard to different
requirements, some of which are summarized below:

- when the class is an AR model, the client may incorporate a
  `#put_in_index` call in an `after_save` or `after_commit` callback.
- the client may wish to implement document indexing in an
  asynchronous manner for performance reasons.
- the client may wish to decide whether to index the document only if
  certain conditions are met.

For all these reasons, `Indexable` only provides the `put_in_index`
instance method for the client to use as he/she sees fit.

## Field Types

`Indexable` supports the following generic types:

- `:integer`
- `:double`
- `:string`: this is a literal string (i.e. should be matched exactly)
- `:string_array`: an array of literal strings
- `:text`: text that can be interpreted as free text by a specific backend
- `:text_array`: an array of text fields
- `:date`: datetime field
- `:boolean`
- `:struct`: used to specify a nested structure

The interpretation of these types by backends are not in the scope of
this document (check Index Guide for more details).

## Document Schemas

The specification of types in the definition of index fields implies
that we can derive the document schema using the `Indexable#schema`
method. E.g. given a `Task` instance:

```ruby
> task.schema
{
  "id" => :integer,
  "last_assigned_at" => :date,
  "type" => :string,
  "workflow" => {
    "id" => :integer,
    "created_at" => :date,
    "notes" => :text_array
  }
}
```

## Custom Field Attributes

The definition of index fields within a class allows for the
specification of custom attributes, for example:

```ruby
class Task < ActiveRecord::Base
  include AgnosticBackend::Indexable
  belongs_to :workflow, class_name: 'Workflow'

  define_index_fields do
    integer :id
    date :last_assigned_at, value: :assigned_at,
         is_column: true, label: 'Last Assigned At'
    string :type, value: proc { task_category.name }
           is_column: true, label: 'Task Type'
    struct :workflow, from: Workflow
  end
end
```

In this example, we have specified two custom attributes for fields
`last_assigned_at` and `is_column`, for use in UI elements.

We can get these options back (say `:is_column`) by passing a block to
`Indexable#schema` (that yields a `FieldType` instance) as follows:

```ruby
> task.schema {|field_type| field_type.get_option('is_column') }
{:id=>nil, :last_assigned_at=>true, :type=>true, ...}
```

Custom attributes can be very useful in a variety of situations; for
example, they can be used in the context of web views in order to
control the visual/behavioural aspects of the document's fields.

## Polymorphic relationships (for ActiveRecord classes)

`Indexable` also supports AR polymorphic relationships as nested
fields. Suppose we have the following model:

```ruby
class Task < ActiveRecord::Base
  include AgnosticBackend::Indexable
  has_one :concrete_task, polymorphic: true

  define_index_fields do
    struct :concrete_task
  end
end
```

that has a polymorphic relationship with a concrete task, which can be
one of various classes, say `ConcreteTaskA` and `ConcreteTaskB`. When
requesting the `Task`'s schema using `Task.schema` the algorithm can
not figure out which class needs to be queried about its schema when
it encounters the `struct` field. As a result, the schema is
incomplete.

This can be overcome by specifying the possible classes that can
constitute a concrete task using the `from` attribute as:

```ruby
class Task < ActiveRecord::Base
  include AgnosticBackend::Indexable
  has_one :concrete_task, polymorphic: true

  define_index_fields do
    struct :concrete_task, from: [ConcreteTaskA, ConcreteTaskB]
  end
end
```

As a result, the schema will include a `concrete_task` field whose
value will be the result of a merge between the schemas of all the
classes specified in the `from` attribute.

## RSpec Matchers

`AgnosticBackends` also supplies `RSpec` matchers for verifying that a
given class is `Indexable` and that it indexes the expected fields.

In your `spec_helper.rb` use the following:

```ruby
require 'agnostic_backend/rspec/matchers'

RSpec.configure do |config|
  config.include AgnosticBackend::RSpec::Matchers
end
```

This gives access to the matchers `be_indexable` and
`define_index_field`. For usage examples, check the
[corresponding test file](matchers_spec.rb).
