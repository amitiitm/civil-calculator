require 'rails_helper'

RSpec.describe Estimate, type: :model do
  it { is_expected.to belong_to(:project) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:construction_package).optional }
  it { is_expected.to have_many(:estimate_line_items).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:version_number) }

  describe "#recalculate_totals!" do
    let(:estimate) { create(:estimate, contingency_percentage: 10, tax_amount: 0) }

    before do
      create(:estimate_line_item, estimate: estimate, item_type: :material, purchase_quantity: 10, rate: 100)
      create(:estimate_line_item, estimate: estimate, item_type: :labour, purchase_quantity: 5, rate: 50)
    end

    it "reconciles the total cost with the underlying line items" do
      estimate.recalculate_totals!

      expect(estimate.material_cost).to eq(1000)
      expect(estimate.labour_cost).to eq(250)
      expect(estimate.contingency_amount).to eq(125)
      expect(estimate.total_cost).to eq(1375)
    end

    it "computes cost per sqft from the project's total built-up area" do
      estimate.recalculate_totals!

      expect(estimate.cost_per_sqft).to eq((estimate.total_cost / estimate.project.total_built_up_area_sqft).round(2))
    end
  end
end

