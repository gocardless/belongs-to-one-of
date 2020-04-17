# frozen_string_literal: true

RSpec.shared_examples "organisation type matches organisation" do
|resource_type_field = "organisation_type"|
  subject(:competitor) { competitor_klass.create(params) }

  let(:params) do
    { name: "Joe Bloggs", organisation: school, resource_type_field => "School" }
  end

  context "when organisation type is specified correctly" do
    it "does not throw error" do
      expect(competitor.errors[resource_type_field]).
        to_not include("organisation_type must match the type of organisation")
    end
  end

  context "when no organisation is specified" do
    let(:params) { { name: "Joe Bloggs" } }

    it "does not throw error" do
      expect(competitor.errors[resource_type_field]).
        to_not include("organisation_type must match the type of organisation")
    end
  end

  context "when an incorrect resource type is specified" do
    let(:params) do
      { name: "Joe Bloggs", organisation: school, resource_type_field => "College" }
    end

    it "throws error" do
      expect(competitor.errors[resource_type_field]).
        to include("organisation_type must match the type of organisation")
    end
  end
end
