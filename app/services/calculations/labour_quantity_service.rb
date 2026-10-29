module Calculations
  # Flat general construction labour charge per sqft of built-up area for a floor.
  class LabourQuantityService
    def initialize(labour_rate:, area_sqft:, label:)
      @labour_rate = labour_rate
      @area_sqft = area_sqft
      @label = label
    end

    def call
      QuantityResult.new(
        category_code: "labour_construction",
        item_name: "#{label} - #{labour_rate.work_type}",
        unit: labour_rate.unit,
        raw_quantity: area_sqft.round(2),
        purchase_quantity: area_sqft.round(2),
        rate: labour_rate.rate,
        amount: (area_sqft * labour_rate.rate).round(2),
        data_source: :assumed,
        item_type: :labour
      )
    end

    private

    attr_reader :labour_rate, :area_sqft, :label
  end
end
