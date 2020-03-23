# frozen_string_literal: true

require "sqlite3"
require "active_record"

# Connect to an in-memory sqlite3 database
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

# Suppress STDOUT schema creation
ActiveRecord::Schema.verbose = false

# Define a minimal database schema
ActiveRecord::Schema.define do
  create_table :competitors do |t|
    t.string :name, null: false
    t.numeric :school_id, null: true
    t.numeric :my_school_id, null: true
    t.numeric :college_id, null: true
    t.numeric :my_college_id, null: true
    t.string :organisation_type, null: true
    t.string :my_organisation_type, null: true
  end

  create_table :schools do |t|
    t.string :name, null: false
  end

  create_table :colleges do |t|
    t.string :name, null: false
  end

  create_table :foos do |t|
    t.string :name, null: false
  end
end

# define School and College class to be used across our specs
class School < ActiveRecord::Base
  self.table_name = :schools
end

class College < ActiveRecord::Base
  self.table_name = :colleges
end

class Foo < ActiveRecord::Base
  self.table_name = :foos
end
