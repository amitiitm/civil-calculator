require 'rails_helper'

RSpec.describe Material, type: :model do
  subject { create(:material) }

  it { is_expected.to belong_to(:material_category) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_uniqueness_of(:code).case_insensitive }

  describe "duplicate material codes" do
    it "is invalid when another material already uses the same code" do
      create(:material, code: "DUP-1")
      duplicate = build(:material, code: "DUP-1")

      expect(duplicate).not_to be_valid
    end
  end

  describe "#rate_for" do
    let(:material) { create(:material, default_rate: 100, quality_grade: "standard") }

    it "falls back to the default rate when no location-specific rate exists" do
      expect(material.rate_for(state: "Maharashtra", city: "Pune")).to eq(100)
    end

    it "prefers the most recent matching location rate over the default" do
      create(:material_rate, material: material, state: "Maharashtra", city: "Pune", quality_grade: "standard", rate: 120, effective_date: 1.day.ago)
      create(:material_rate, material: material, state: "Maharashtra", city: "Pune", quality_grade: "standard", rate: 130, effective_date: Date.current)

      expect(material.rate_for(state: "Maharashtra", city: "Pune")).to eq(130)
    end
  end
end

