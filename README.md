# belongs_to_one_of
Gem to support activemodel relations where one model can be a child of one of many models.
Unlike rails polymorphic relations, this supports having a separate `id` column for each parent 
model type (e.g. `school_id` and `college_id` instead of just `organisation_id`). This is desirable
(in some cases) to enable the database to use foreign keys.
The gem will also error if you try to set a resource which isn't one of the specified classes, unlike
a rails polymorphic relation which will accept any model class.

## Installation

Install the package from Rubygems:
```shell script
gem install belongs_to_one_of
```

Or add it to your gemfile
```
gem 'belongs_to_one_of'
```

## Quick Start

In our examples, we will be targeting a class `Competitor` which can either belong to a `School` or a `College`.
We will consider this more general concept an `organisation`.

Our code will say:

> This model belongs to an organisation, which might be a School or might be a College

This allows us to store the association in the columns `school_id` and `college_id`, which can use foreign keys,
but for the 99% of your code which doesn't care which is which, they can just call a method `organisation` or 
`organisation_id` to access the resource.

The library adds a new association to `ActiveRecord` called `belongs_to_one_of :organisation, `. To use it, simply call this
hook in your `ActiveRecord` class:

```ruby
class Competitor < ActiveRecord::Base
  belongs_to_one_of :organisation, %i[school college]
end

class School < ActiveRecord::Base
  has_many :competitors
end 

class College < ActiveRecord::Base
  has_many :competitors
end 

school = School.new

my_competitor = Competitor.create(name: 'jack', organisation: school)

my_competitor.organisation
# => school

my_competitor.organisation_id == school.id
# => true 
```

Note that this helper calls `belongs_to :school, optional:true` and `belongs_to :college, optional:true`, so you don't have to.

## Available methods

The hook defines a few methods on your class. The names are dynamic, we will use 'organisation' as our example
(as per above):

### Validators

#### `belongs_to_exactly_one_[organisation]`
A validator that can be used to check that a model belongs to exactly one organisation

#### `belongs_to_at_most_one_[organisation]`
A validator that can be used to check that a model belongs to either no organisations or one organisation

#### `[organisation_type]_matches_[organisation]`
A validator that can be used to check that the type of model matches the model. Only relevant when 
`include_type_column` is true

### Getters & Setters

#### `[organisation]=`
Allows you to create a new instance of the model with the interface:

```ruby
Competitor.new(
  organisation: my_school,
  name: "Joe Bloggs"
)
```

This will raise a `ModelNotFound` exception if the organisation is not one of the permitted model types

#### `[organisation]`
Allows you to get the linked resource via `.organisation` e.g.:
```ruby
my_competitor.organisation
```
#### `[organisation]_id`
Allows you to get the linked resource's id via `.organisation_id` e.g.:
```ruby
my_competitor.organisation_id
``` 

#### `[organisation]_type`
This is only set when the relation is not `include_type_column` (see below). This allows you to access the resource type via
`.organisation_type` e.g.:
```ruby
my_competitor.organisation_type
# => 'School'
``` 

## Configuration Options

### `include_type_column`

By default, the library assumes that the underlying table looks like:

`id` | `name` | `school_id` | `college_id`
----|----|---|---
1 | Aaron J Aaronson | | COL123
2 | Betty F Parker | SCH456 | 

however you can set `include_type_column: true` to explicitly store what type of model is connected, e.g.:

```ruby
  belongs_to_one_of :organisation, %i[school college], include_type_column: true
```

`id` | `name` | `organisation_type` | `school_id` | `college_id`
----|----|---|---|---
1 | Aaron J Aaronson | College | | COL123
2 | Betty F Parker | School | SCH456 | 

if the column is not called `[organisation]_type`, you can specify the column name e.g.

```ruby
  belongs_to_one_of :organisation, %i[school college], include_type_column: :type_of_organisation
```

`id` | `name` | `type_of_organisation` | `school_id` | `college_id`
----|----|---|---|---
1 | Aaron J Aaronson | College | | COL123
2 | Betty F Parker | School | SCH456 | 


### `type_column_value`

If you have `include_type_column:true` set, by default we assume you want to store the classname in the db.
However, there may be some logic that you want to apply. If you pass a Proc to `type_column_value` 
you can add your own logic to determine what goes into the db.

```ruby
  belongs_to_one_of :organisation,  %i[school college], include_type_column: true,
                                                       type_column_value: ->(resource) { resource.class.downcase }
```

`id` | `name` | `organisation_type` | `school_id` | `college_id`
----|----|---|---|---
1 | Aaron J Aaronson | college | | COL123
2 | Betty F Parker | school | SCH456 | 
