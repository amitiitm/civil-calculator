require "rails_helper"

RSpec.describe Calculations::CementQuantityService do
  let(:material) { create(:material, formula_identifier: "cement", wastage_percentage: 2, default_rate: 420) }

  before { create(:calculation_formula, :cement_mix, category_code: "cement_rcc") }

  subject(:result) { described_class.new(material: material, activity: "rcc", wet_volume_cft: 100).call }

  it "converts cement volume into whole bags" do
    expect(result.purchase_quantity).to eq(result.purchase_quantity.to_i)
  end

  it "uses the activity-specific mix ratio in the category code" do
    expect(result.category_code).to eq("cement_rcc")
  end

  context "when the activity has no configured formula" do
    subject(:result) { described_class.new(material: material, activity: "plaster", wet_volume_cft: 100).call }

    it "raises a domain-specific error instead of guessing a ratio" do
      expect { result }.to raise_error(Calculations::MissingFormulaParameterError)
    end
  end
end
