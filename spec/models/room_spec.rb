require 'rails_helper'

RSpec.describe Room, type: :model do
  subject(:room) { build(:room, length_ft: 12, width_ft: 10, wall_height_ft: 9) }

  it { is_expected.to belong_to(:project_floor) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_numericality_of(:length_ft).is_greater_than(0) }

  describe "#area_sqft" do
    it "multiplies length by width" do
      expect(room.area_sqft).to eq(120)
    end
  end

  describe "#perimeter_ft" do
    it "sums twice the length and width" do
      expect(room.perimeter_ft).to eq(44)
    end
  end

  describe "#wall_area_sqft" do
    it "multiplies perimeter by wall height" do
      expect(room.wall_area_sqft).to eq(396)
    end
  end

  describe "conflicting/invalid room dimensions" do
    it "rejects a zero width" do
      room.width_ft = 0

      expect(room).not_to be_valid
    end
  end
end

