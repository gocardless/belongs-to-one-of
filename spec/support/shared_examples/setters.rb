# frozen_string_literal: true

RSpec.shared_examples "responds to setters" do |school_id_field = "school_id"|
  subject(:competitor) { competitor_klass.create(params) }

  let(:params) { { name: "Joe Bloggs", organisation: school } }

  context "when we set organisation" do
    it "the resource is accessible via .school" do
      expect(competitor.school).to eq(school)
    end
  end

  context "when we set school" do
    let(:params) { { name: "Joe Bloggs", school: school } }

    it "the resource is accessible via .school" do
      expect(competitor.school).to eq(school)
    end
  end

  context "when we set #{school_id_field}" do
    let(:params) { { name: "Joe Bloggs", school_id_field => school.id } }

    it "the resource is accessible via .school" do
      expect(competitor.school).to eq(school)
    end
  end

  context "when we set school and then college" do
    let(:params) { { name: "Joe Bloggs", organisation: school } }

    it "clears the school if we set a college via organisation" do
      competitor.organisation = college
      expect(competitor.school).to eq(nil)
    end
  end
end
