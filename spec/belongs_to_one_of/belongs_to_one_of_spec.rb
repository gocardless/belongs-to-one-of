# frozen_string_literal: true

require "spec_helper"
require_relative "spec_helpers/database"
require_relative "../support/shared_examples/setters"
require_relative "../support/shared_examples/getters"
require_relative "../support/shared_examples/validators/belongs_to_exactly_one"
require_relative "../support/shared_examples/validators/belongs_to_at_most_one"
require_relative "../support/shared_examples/validators/organisation_type_matches_organisation" # rubocop:disable Metrics/LineLength
require "pry-byebug"

RSpec.context "Belongs to one of" do
  let(:competitor_klass) do
    Class.new(ActiveRecord::Base) do
      self.table_name = :competitors
      belongs_to_one_of :organisation, %i[college school]

      # we need to define this so that activerecord doesn't explode
      # when it tries to associate another model
      def self.name
        "competitor"
      end
    end
  end

  let(:school) { School.create(name: "School of Rock") }

  let(:college) { College.create(name: "Eton College") }

  let(:competitor) { competitor_klass.new(name: "Joe Bloggs", organisation: school) }

  context "with default options" do
    it "saves the record" do
      competitor = competitor_klass.new(name: "Joe Bloggs", organisation: school)
      expect { competitor.save! }.to_not raise_error
    end

    it_behaves_like "responds to setters"

    it_behaves_like "responds to getters"

    it "doesn't set the foreign_key on the relation" do
      college = competitor_klass.reflect_on_association(:college)
      expect(college.options).to_not have_key(:foreign_key)
    end

    context "and has belongs_to_exactly_one validator" do
      let(:competitor_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = :competitors
          belongs_to_one_of :organisation, %i[college school]

          validate :belongs_to_exactly_one_organisation

          def self.name
            "competitor"
          end
        end
      end

      it_behaves_like "belongs to exactly one organisation"
    end

    context "and has belongs_to_at_most_one validator" do
      let(:competitor_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = :competitors
          belongs_to_one_of :organisation, %i[college school]

          validate :belongs_to_at_most_one_organisation

          def self.name
            "competitor"
          end
        end
      end

      it_behaves_like "belongs to at most one organisation"
    end
  end

  context "with custom id columns" do
    let(:competitor_klass) do
      Class.new(ActiveRecord::Base) do
        self.table_name = :competitors
        belongs_to_one_of :organisation,
                          { college: :my_college_id, school: :my_school_id }

        def self.name
          "competitor"
        end
      end
    end

    it "saves the record" do
      competitor = competitor_klass.new(name: "Joe Bloggs", organisation: school)
      expect { competitor.save! }.to_not raise_error
    end

    it_behaves_like "responds to setters", "my_school_id"

    it_behaves_like "responds to getters", "organisation_type", "my_school_id"

    it "configures a foreign_key on the relation" do
      college = competitor_klass.reflect_on_association(:college)
      expect(college.options).to include(foreign_key: :my_college_id)
    end

    context "and has belongs_to_exactly_one validator" do
      let(:competitor_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = :competitors
          belongs_to_one_of :organisation, %i[college school]

          validate :belongs_to_exactly_one_organisation

          def self.name
            "competitor"
          end
        end
      end

      it_behaves_like "belongs to exactly one organisation"
    end

    context "and has belongs_to_at_most_one validator" do
      let(:competitor_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = :competitors
          belongs_to_one_of :organisation, %i[college school]

          validate :belongs_to_at_most_one_organisation

          def self.name
            "competitor"
          end
        end
      end

      it_behaves_like "belongs to at most one organisation"
    end
  end

  context "with include_type_column=true" do
    let(:competitor_klass) do
      Class.new(ActiveRecord::Base) do
        self.table_name = :competitors
        belongs_to_one_of :organisation, %i[college school], include_type_column: true

        def self.name
          "competitor"
        end
      end
    end

    it "saves the record" do
      competitor = competitor_klass.new(name: "Joe Bloggs", organisation: school)
      expect { competitor.save! }.to_not raise_error
    end

    it_behaves_like "responds to setters"

    it_behaves_like "responds to getters"

    context "and has belongs_to_exactly_one validator" do
      let(:competitor_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = :competitors
          belongs_to_one_of :organisation, %i[college school], include_type_column: true

          validate :belongs_to_exactly_one_organisation

          def self.name
            "competitor"
          end
        end
      end

      it_behaves_like "belongs to exactly one organisation"
    end

    context "and has belongs_to_at_most_one validator" do
      let(:competitor_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = :competitors
          belongs_to_one_of :organisation, %i[college school], include_type_column: true

          validate :belongs_to_at_most_one_organisation

          def self.name
            "competitor"
          end
        end
      end

      it_behaves_like "belongs to at most one organisation"
    end

    context "and has organisation_type_matches_organisation validator" do
      let(:competitor_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = :competitors
          belongs_to_one_of :organisation, %i[college school], include_type_column: true

          validate :organisation_type_matches_organisation

          def self.name
            "competitor"
          end
        end
      end

      it_behaves_like "organisation type matches organisation"
    end
  end

  context "with include_type_column=my_organisation_type" do
    let(:competitor_klass) do
      Class.new(ActiveRecord::Base) do
        self.table_name = :competitors
        belongs_to_one_of :organisation, %i[college school],
                          include_type_column: :my_organisation_type

        def self.name
          "competitor"
        end
      end
    end

    it "saves the record" do
      competitor = competitor_klass.new(name: "Joe Bloggs", organisation: school)
      expect { competitor.save! }.to_not raise_error
    end

    it_behaves_like "responds to setters"

    it_behaves_like "responds to getters", "my_organisation_type"

    context "and has belongs_to_exactly_one validator" do
      let(:competitor_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = :competitors
          belongs_to_one_of :organisation, %i[college school], include_type_column: true

          validate :belongs_to_exactly_one_organisation

          def self.name
            "competitor"
          end
        end
      end

      it_behaves_like "belongs to exactly one organisation"
    end

    context "and has belongs_to_at_most_one validator" do
      let(:competitor_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = :competitors
          belongs_to_one_of :organisation, %i[college school], include_type_column: true

          validate :belongs_to_at_most_one_organisation

          def self.name
            "competitor"
          end
        end
      end

      it_behaves_like "belongs to at most one organisation"
    end
  end

  context "with incorrect options" do
    context "with only one argument" do
      let(:competitor_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = :competitors
          belongs_to_one_of :organisation

          def self.name
            "competitor"
          end
        end
      end

      it "throws an error" do
        expect { competitor.save! }.to raise_error ArgumentError
      end
    end

    context "with an incorrect argument type" do
      let(:competitor_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = :competitors
          belongs_to_one_of %i[college school], :organisation

          def self.name
            "competitor"
          end
        end
      end

      it "throws an error" do
        expect { competitor.save! }.
          to raise_error BelongsToOneOf::BelongsToOneOfModel::InvalidParamsException
      end
    end

    context "with a missing id column" do
      let(:competitor_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = :competitors
          belongs_to_one_of :organisation,
                            { school: :not_a_school_id, college: :college_id }

          def self.name
            "competitor"
          end
        end
      end

      it "throws an error" do
        expect { competitor.save! }.to raise_error ActiveModel::MissingAttributeError
      end
    end

    context "with a missing resource_type_field column" do
      let(:competitor_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = :competitors
          belongs_to_one_of :organisation, %i[college school],
                            include_type_column: :not_a_column

          def self.name
            "competitor"
          end
        end
      end

      it "throws an error" do
        expect { competitor.save! }.to raise_error NoMethodError
      end
    end
  end

  context "can overwrite methods" do
    let(:competitor_klass) do
      Class.new(ActiveRecord::Base) do
        self.table_name = :competitors
        belongs_to_one_of :organisation, %i[college school]

        def self.name
          "competitor"
        end

        def organisation_id
          "foo"
        end
      end
    end

    it "calls my special method" do
      expect(competitor.organisation_id).to eq("foo")
    end
  end
end
