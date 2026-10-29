require "rails_helper"

RSpec.describe Calculations::AggregateQuantityService do
  let(:material) { create(:material, formula_identifier: "aggregate", wastage_percentage: 5, default_rate: 45) }

  before { create(:calculation_formula, :cement_mix, category_code: "cement_rcc") }

  subject(:result) { described_class.new(material: material, activity: "rcc", wet_volume_cft: 100).call }

  it "returns a positive aggregate quantity for RCC mixes" do
    expect(result.raw_quantity).to be > 0
  end

  context "when the mix ratio has no aggregate part (e.g. masonry mortar)" do
    before { create(:calculation_formula, :mortar_mix, category_code: "cement_masonry") }

    subject(:result) { described_class.new(material: material, activity: "masonry", wet_volume_cft: 100).call }

    it "returns zero aggregate quantity" do
      expect(result.raw_quantity).to eq(BigDecimal("0"))
    end
  end
end
