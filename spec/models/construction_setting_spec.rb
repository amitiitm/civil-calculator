require 'rails_helper'

RSpec.describe ConstructionSetting, type: :model do
  subject { create(:construction_setting) }

  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_uniqueness_of(:key).case_insensitive }

  describe ".fetch" do
    it "returns the type-cast value for a known key" do
      create(:construction_setting, key: "slab_thickness_in", value: "5", data_type: "decimal")

      expect(ConstructionSetting.fetch("slab_thickness_in")).to eq(BigDecimal("5"))
    end

    it "returns an integer for an integer data type" do
      create(:construction_setting, key: "default_column_count_per_floor", value: "4", data_type: "integer")

      expect(ConstructionSetting.fetch("default_column_count_per_floor")).to eq(4)
    end

    it "returns the given default when the key is missing" do
      expect(ConstructionSetting.fetch("missing_key", 42)).to eq(42)
    end
  end
end

