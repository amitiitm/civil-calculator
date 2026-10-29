require "rails_helper"

RSpec.describe Calculations::SteelQuantityService do
  let(:material) { create(:material, formula_identifier: "steel", wastage_percentage: 3, default_rate: 68) }

  before { create(:calculation_formula, :steel, category_code: "steel_slab") }

  subject(:result) { described_class.new(material: material, element_type: "slab", concrete_volume_cft: 50).call }

  it "always flags the result as an assumption, never calculated" do
    expect(result.data_source).to eq(:assumed)
  end

  it "scales linearly with concrete volume" do
    expect(result.raw_quantity).to eq(BigDecimal("250.0"))
  end

  context "when no steel factor is configured for the element type" do
    subject(:result) { described_class.new(material: material, element_type: "beam", concrete_volume_cft: 50).call }

    it "raises a domain-specific error" do
      expect { result }.to raise_error(Calculations::MissingFormulaParameterError)
    end
  end
end
