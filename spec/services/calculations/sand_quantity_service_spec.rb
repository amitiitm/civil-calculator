require "rails_helper"

RSpec.describe Calculations::SandQuantityService do
  let(:material) { create(:material, formula_identifier: "sand", wastage_percentage: 5, default_rate: 55) }

  before { create(:calculation_formula, :cement_mix, category_code: "cement_rcc") }

  subject(:result) { described_class.new(material: material, activity: "rcc", wet_volume_cft: 100).call }

  it "returns a positive sand quantity for a non-zero concrete volume" do
    expect(result.raw_quantity).to be > 0
  end

  it "applies wastage on top of the raw quantity" do
    expect(result.purchase_quantity).to be >= result.raw_quantity
  end
end
