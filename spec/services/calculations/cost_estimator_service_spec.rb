require "rails_helper"

RSpec.describe Calculations::CostEstimatorService do
  let(:user) { create(:user) }
  let(:package) { create(:construction_package) }

  let!(:bricks_category) { create(:material_category, code: "bricks") }
  let!(:cement_category) { create(:material_category, code: "cement") }
  let!(:sand_category) { create(:material_category, code: "sand") }
  let!(:aggregate_category) { create(:material_category, code: "aggregate") }
  let!(:steel_category) { create(:material_category, code: "steel") }
  let!(:tiles_category) { create(:material_category, code: "tiles") }
  let!(:electrical_category) { create(:material_category, code: "electrical") }
  let!(:granite_category) { create(:material_category, code: "granite") }

  let!(:brick_material) { create(:material, material_category: bricks_category, formula_identifier: "bricks", default_rate: 8) }
  let!(:cement_material) { create(:material, material_category: cement_category, formula_identifier: "cement", default_rate: 420) }
  let!(:sand_material) { create(:material, material_category: sand_category, formula_identifier: "sand", default_rate: 55) }
  let!(:aggregate_material) { create(:material, material_category: aggregate_category, formula_identifier: "aggregate", default_rate: 45) }
  let!(:steel_material) { create(:material, material_category: steel_category, formula_identifier: "steel", default_rate: 68) }
  let!(:tile_material) { create(:material, material_category: tiles_category, formula_identifier: "tiles", quality_grade: "standard", default_rate: 50) }
  let!(:electrical_material) { create(:material, material_category: electrical_category, formula_identifier: "electrical", default_rate: 1200) }
  let!(:granite_material) { create(:material, material_category: granite_category, formula_identifier: "granite", default_rate: 150) }
  let!(:general_labour_rate) { create(:labour_rate, work_type: "General Construction Labour", unit: "sqft", rate: 350) }

  let!(:settings) do
    {
      "wall_thickness_external_in" => "9", "wall_thickness_internal_in" => "4.5", "slab_thickness_in" => "5",
      "column_width_in" => "9", "column_depth_in" => "9", "footing_length_ft" => "4", "footing_width_ft" => "4",
      "footing_depth_ft" => "3", "default_column_count_per_floor" => "4", "default_contingency_percentage" => "5"
    }.each { |key, value| create(:construction_setting, key: key, value: value, data_type: "decimal") }
  end

  before do
    create(:calculation_formula, :bricks, category_code: "bricks")
    create(:calculation_formula, :mortar_mix, category_code: "cement_masonry")
    create(:calculation_formula, :cement_mix, category_code: "cement_rcc")
    create(:calculation_formula, :steel, category_code: "steel_slab")
    create(:calculation_formula, :steel, category_code: "steel_column")
    create(:calculation_formula, :steel, category_code: "steel_footing")
  end

  let(:project) { create(:project, user: user) }
  let!(:floor) { create(:project_floor, project: project, floor_number: 1, bhk_type: :bhk_2) }
  let!(:room) { create(:room, project_floor: floor) }

  subject(:call_service) { described_class.new(project: project, user: user, construction_package: package).call }

  it "succeeds and persists an estimate with line items" do
    result = call_service

    expect(result.success?).to be(true)
    expect(result.estimate).to be_persisted
    expect(result.estimate.estimate_line_items.count).to be > 0
  end

  it "reconciles the total cost with the sum of its line items" do
    estimate = call_service.estimate
    subtotal = estimate.material_cost + estimate.labour_cost + estimate.equipment_cost + estimate.transport_cost

    expect(estimate.total_cost).to eq((subtotal + estimate.contingency_amount + estimate.tax_amount).round(2))
  end

  it "increments the version number on successive estimates for the same project" do
    first = described_class.new(project: project, user: user, construction_package: package).call.estimate
    second = described_class.new(project: project, user: user, construction_package: package).call.estimate

    expect(second.version_number).to eq(first.version_number + 1)
  end

  it "flags steel quantities as assumed, not calculated" do
    estimate = call_service.estimate
    steel_items = estimate.estimate_line_items.where(material_category_name: %w[steel_slab steel_column steel_footing])

    expect(steel_items).to all(be_assumed)
  end

  it "sums doors/windows per floor instead of once for the whole project" do
    second_floor = create(:project_floor, project: project, floor_number: 2, name: "First Floor", bhk_type: :bhk_1)
    estimate = call_service.estimate

    door_items = estimate.estimate_line_items.where(material_category_name: "doors_average")
    expect(door_items.where(floor_label: floor.name).sum(:purchase_quantity)).to eq(7)
    expect(door_items.where(floor_label: second_floor.name).sum(:purchase_quantity)).to eq(5)
  end

  it "skips doors/windows for a floor with no bhk_type (manually added, not BHK-driven)" do
    blank_floor = create(:project_floor, project: project, floor_number: 2, name: "First Floor", bhk_type: nil)
    estimate = call_service.estimate

    expect(estimate.estimate_line_items.where(floor_label: blank_floor.name, material_category_name: "doors_average")).to be_empty
  end

  it "adds a general construction labour line item priced per sqft of floor footprint" do
    estimate = call_service.estimate
    labour_item = estimate.estimate_line_items.find_by(material_category_name: "labour_construction", floor_label: floor.name)

    expect(labour_item.amount).to eq((floor.footprint_sqft * 350).round(2))
  end

  it "adds an electrical allowance based on the floor's total electrical points" do
    estimate = call_service.estimate
    electrical_item = estimate.estimate_line_items.find_by(material_category_name: "electrical", floor_label: floor.name)

    expect(electrical_item.purchase_quantity).to eq(room.electrical_point_count)
  end

  it "adds a tile flooring line item per room, priced by the project's construction quality" do
    estimate = call_service.estimate
    tile_item = estimate.estimate_line_items.find_by(material_category_name: "tiles", floor_label: floor.name)

    expect(tile_item.rate).to eq(BigDecimal("50"))
  end

  it "adds a project-wide staircase granite allowance scaled by full floor count" do
    estimate = call_service.estimate
    staircase_item = estimate.estimate_line_items.find_by(material_category_name: "granite_stairs")

    expect(staircase_item.floor_label).to eq("Staircases")
    expect(staircase_item.purchase_quantity).to be > 0
  end

  context "when a required formula is missing (e.g. steel_column not configured)" do
    before { CalculationFormula.find_by(category_code: "steel_column").destroy }

    it "fails without persisting a partial estimate" do
      expect { call_service }.not_to change(Estimate, :count)
      expect(call_service.success?).to be(false)
      expect(call_service.error).to be_present
    end
  end

  context "when the project has no floors" do
    let(:floor) { nil }
    let(:room) { nil }
    let(:project) { create(:project, user: user, floors_count: 1) }

    it "still produces a result without raising" do
      expect { call_service }.not_to raise_error
    end
  end

  context "when a floor has a reduced footprint_percentage (partial top floor)" do
    let!(:full_floor) { create(:project_floor, project: project, floor_number: 2, name: "First Floor", footprint_percentage: 100) }
    let!(:partial_floor) { create(:project_floor, project: project, floor_number: 3, name: "Second Floor", footprint_percentage: 50) }

    it "costs the partial floor's slab less than a full-footprint floor" do
      estimate = call_service.estimate

      full_floor_cost = estimate.estimate_line_items.where(floor_label: full_floor.name).sum(:amount)
      partial_floor_cost = estimate.estimate_line_items.where(floor_label: partial_floor.name).sum(:amount)

      expect(partial_floor_cost).to be < full_floor_cost
    end
  end
end
