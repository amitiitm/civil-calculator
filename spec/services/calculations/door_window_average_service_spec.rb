require "rails_helper"

RSpec.describe Calculations::DoorWindowAverageService do
  subject(:results) { described_class.new(bhk_type: "bhk_2", window_material: "aluminium").call }

  it "returns a door and a window line item" do
    expect(results.map(&:category_code)).to contain_exactly("doors_average", "windows_average")
  end

  it "flags both as assumptions, not calculated from actual rooms" do
    expect(results).to all(have_attributes(data_source: :assumed))
  end

  describe "door averages" do
    subject(:door_result) { results.find { |r| r.category_code == "doors_average" } }

    it "uses the configured average door count for the BHK type" do
      create(:construction_setting, key: "avg_door_count_bhk_2", value: "7", data_type: "integer")

      expect(door_result.purchase_quantity).to eq(7)
    end

    it "prices doors at the flat chokhat-inclusive rate" do
      create(:construction_setting, key: "door_cost_with_chokhat", value: "7000", data_type: "decimal")

      expect(door_result.amount).to eq(door_result.purchase_quantity * BigDecimal("7000"))
    end
  end

  describe "window averages" do
    it "prices aluminium windows at the aluminium rate" do
      create(:construction_setting, key: "window_rate_aluminium_per_sqft", value: "250", data_type: "decimal")
      aluminium_result = described_class.new(bhk_type: "bhk_2", window_material: "aluminium").call.find { |r| r.category_code == "windows_average" }

      expect(aluminium_result.rate).to eq(BigDecimal("250"))
    end

    it "prices upvc windows higher than aluminium" do
      create(:construction_setting, key: "window_rate_aluminium_per_sqft", value: "250", data_type: "decimal")
      create(:construction_setting, key: "window_rate_upvc_per_sqft", value: "500", data_type: "decimal")

      aluminium_amount = described_class.new(bhk_type: "bhk_2", window_material: "aluminium").call.find { |r| r.category_code == "windows_average" }.amount
      upvc_amount = described_class.new(bhk_type: "bhk_2", window_material: "upvc").call.find { |r| r.category_code == "windows_average" }.amount

      expect(upvc_amount).to be > aluminium_amount
    end
  end

  context "when no settings are configured for an unusual BHK type" do
    subject(:results) { described_class.new(bhk_type: "custom_layout").call }

    it "falls back to sensible in-code defaults instead of raising" do
      expect { results }.not_to raise_error
    end
  end
end
