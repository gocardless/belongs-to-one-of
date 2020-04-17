# frozen_string_literal: true

RSpec.shared_examples "responds to getters" do
|resource_type_field = "organisation_type", school_id_field = "school_id"|
  subject(:competitor) { competitor_klass.create(params) }

  let(:params) { { name: "Joe Bloggs", organisation: school } }

  context "when we get organisation" do
    it "returns the resource id" do
      expect(competitor.organisation).to eq(school)
    end
  end

  context "when we get school" do
    it "returns the resource id" do
      expect(competitor.school).to eq(school)
    end
  end

  context "when we get organisation_id" do
    it "returns the resource id" do
      expect(competitor.organisation_id).to eq(school.id)
    end
  end

  context "when we get #{school_id_field}" do
    it "returns the resource id" do
      expect(competitor.send(school_id_field)).to eq(school.id)
    end
  end

  context "when we get #{resource_type_field}" do
    it "returns the resource classname" do
      expect(competitor.send(resource_type_field)).to eq(school.class.name)
    end
  end
end
