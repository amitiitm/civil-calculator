require 'rails_helper'

RSpec.describe Project, type: :model do
  subject(:project) { build(:project) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:project_floors).dependent(:destroy) }
  it { is_expected.to have_many(:estimates).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_numericality_of(:plot_length_ft).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:floors_count).is_greater_than(0) }

  describe "floors_count half-step validation" do
    it "accepts whole and half values" do
      project.floors_count = 2.5

      expect(project).to be_valid
    end

    it "rejects values that aren't in half-floor increments" do
      project.floors_count = 2.3

      expect(project).not_to be_valid
      expect(project.errors[:floors_count]).to include(/half-floor increments/)
    end
  end

  describe "#full_floors_count and #partial_top_floor?" do
    it "splits a 2.5 floor count into 2 full floors plus a partial top floor" do
      project.floors_count = 2.5

      expect(project.full_floors_count).to eq(2)
      expect(project.partial_top_floor?).to be(true)
    end

    it "has no partial top floor for a whole floor count" do
      project.floors_count = 2

      expect(project.full_floors_count).to eq(2)
      expect(project.partial_top_floor?).to be(false)
    end
  end

  describe "#plot_area_sqft" do
    it "multiplies plot length by plot width" do
      project.plot_length_ft = 40
      project.plot_width_ft = 60

      expect(project.plot_area_sqft).to eq(2400)
    end
  end

  describe "construction footprint validation" do
    it "is invalid when the construction footprint exceeds the plot area" do
      project.plot_length_ft = 10
      project.plot_width_ft = 10
      project.construction_length_ft = 20
      project.construction_width_ft = 20

      expect(project).not_to be_valid
      expect(project.errors[:base]).to include(/exceeds plot area/)
    end

    it "is valid when the construction footprint fits within the plot" do
      project.plot_length_ft = 40
      project.plot_width_ft = 60
      project.construction_length_ft = 30
      project.construction_width_ft = 50

      expect(project).to be_valid
    end
  end

  describe "zero/invalid dimensions" do
    it "rejects a zero plot length" do
      project.plot_length_ft = 0

      expect(project).not_to be_valid
    end

    it "rejects a zero floor count" do
      project.floors_count = 0

      expect(project).not_to be_valid
    end
  end
end
