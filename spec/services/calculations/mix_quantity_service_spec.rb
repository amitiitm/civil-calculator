require "rails_helper"

RSpec.describe Calculations::MixQuantityService do
  it "splits dry volume across mix ratio parts" do
    result = described_class.new(wet_volume_cft: 100, mix_ratio: [ 1, 2, 4 ], dry_volume_factor: 1.5).call

    expect(result.cement_volume_cft).to eq(BigDecimal("150") / 7)
    expect(result.sand_volume_cft).to eq(BigDecimal("300") / 7)
    expect(result.aggregate_volume_cft).to eq(BigDecimal("600") / 7)
  end

  it "returns zero aggregate volume when the mix has no aggregate part" do
    result = described_class.new(wet_volume_cft: 100, mix_ratio: [ 1, 6, 0 ], dry_volume_factor: 1.33).call

    expect(result.aggregate_volume_cft).to eq(BigDecimal("0"))
  end

  it "returns zero volumes for a zero wet volume" do
    result = described_class.new(wet_volume_cft: 0, mix_ratio: [ 1, 2, 4 ], dry_volume_factor: 1.54).call

    expect(result.cement_volume_cft).to eq(BigDecimal("0"))
  end
end
