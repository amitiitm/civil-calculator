require "rails_helper"

RSpec.describe Projects::DefaultLayoutService do
  let(:user) { create(:user) }

  describe "a whole floor count" do
    let(:project) { create(:project, user: user, floors_count: 2, bhk_type: :bhk_2) }

    it "creates one full-footprint floor per floor count" do
      described_class.new(project).call

      expect(project.project_floors.count).to eq(2)
      expect(project.project_floors.pluck(:footprint_percentage).uniq).to eq([ BigDecimal("100") ])
    end

    it "populates each floor with the BHK's default room layout" do
      described_class.new(project).call

      ground_floor = project.project_floors.find_by(floor_number: 1)
      expect(ground_floor.rooms.pluck(:room_type)).to contain_exactly(
        "living_room", "kitchen", "master_bedroom", "bedroom", "bathroom", "bathroom"
      )
    end
  end

  describe "a partial (.5) floor count" do
    let(:project) { create(:project, user: user, floors_count: 2.5, bhk_type: :bhk_2) }

    it "adds one extra floor at 50% footprint" do
      described_class.new(project).call

      expect(project.project_floors.count).to eq(3)
      top_floor = project.project_floors.order(:floor_number).last
      expect(top_floor.footprint_percentage).to eq(BigDecimal("50"))
    end

    it "downgrades the top floor's BHK layout by one tier" do
      described_class.new(project).call

      top_floor = project.project_floors.order(:floor_number).last
      expect(top_floor.rooms.pluck(:room_type)).to contain_exactly("living_room", "kitchen", "bedroom", "bathroom")
    end
  end

  context "when the project uses a custom layout" do
    let(:project) { create(:project, user: user, bhk_type: :custom_layout) }

    it "does not auto-generate any floors" do
      described_class.new(project).call

      expect(project.project_floors.count).to eq(0)
    end
  end

  context "when the project already has floors" do
    let(:project) { create(:project, user: user, bhk_type: :bhk_2) }

    before { create(:project_floor, project: project, floor_number: 1) }

    it "does not add duplicate floors" do
      described_class.new(project).call

      expect(project.project_floors.count).to eq(1)
    end
  end
end
