require "rails_helper"

RSpec.describe Calculations::BrickQuantityService do
  let(:material) { create(:material, formula_identifier: "bricks", wastage_percentage: 5, default_rate: 8) }

  before { create(:calculation_formula, :bricks) }

  subject(:result) do
    described_class.new(
      material: material, wall_length_ft: 20, wall_height_ft: 10, wall_thickness_in: 9, opening_area_sqft: 20
    ).call
  end

  it "computes net volume after subtracting openings" do
    expect(result.raw_quantity).to be > 0
  end

  it "applies wastage to get the purchase quantity" do
    expect(result.purchase_quantity).to be >= result.raw_quantity
  end

  it "rounds the purchase quantity up to a whole brick" do
    expect(result.purchase_quantity).to eq(result.purchase_quantity.to_i)
  end

  it "prices the amount using the material rate" do
    expect(result.amount).to eq((result.purchase_quantity * result.rate).round(2))
  end

  context "when openings consume the entire wall" do
    subject(:result) do
      described_class.new(
        material: material, wall_length_ft: 10, wall_height_ft: 10, wall_thickness_in: 9, opening_area_sqft: 1000
      ).call
    end

    it "never returns a negative quantity" do
      expect(result.raw_quantity).to be >= 0
    end
  end

  context "when no active formula is configured for bricks" do
    before { CalculationFormula.where(category_code: "bricks").update_all(active: false) }

    it "raises a domain-specific error" do
      expect { result }.to raise_error(Calculations::MissingFormulaParameterError)
    end
  end
end
