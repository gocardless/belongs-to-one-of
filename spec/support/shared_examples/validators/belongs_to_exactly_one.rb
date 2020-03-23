# frozen_string_literal: true

RSpec.shared_examples "belongs to exactly one organisation" do
  subject(:competitor) { competitor_klass.create(params) }

  let(:params) { { name: "Joe Bloggs", organisation: school } }

  context "when organisation is specified correctly" do
    it "does not throw error" do
      expect(competitor.errors[:base]).to_not include("model must belong to exactly one organisation")
    end
  end

  context "when no organisation is specified" do
    let(:params) { { name: "Joe Bloggs" } }

    it "throws error" do
      expect(competitor.errors[:base]).to include("model must belong to exactly one organisation")
    end
  end

  context "when multiple resources are specified" do
    let(:params) { { name: "Joe Bloggs", school: school, college: college } }

    it "throws error" do
      expect(competitor.errors[:base]).to include("model must belong to exactly one organisation")
    end
  end
end
