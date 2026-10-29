module Calculations
  # Cement is calculated per activity (rcc/masonry/plaster/flooring/screed) using that
  # activity's configured mix ratio - never a single fixed rate for all concrete works.
  class CementQuantityService
    include FormulaLookup

    def initialize(material:, activity:, wet_volume_cft:, state: nil, city: nil)
      @material = material
      @activity = activity.to_s
      @wet_volume_cft = BigDecimal(wet_volume_cft.to_s)
      @state = state
      @city = city
    end

    def call
      formula = formula_for("cement_#{@activity}")
      mix = MixQuantityService.new(
        wet_volume_cft: @wet_volume_cft,
        mix_ratio: [
          parameter(formula, "cement_ratio"),
          parameter(formula, "sand_ratio"),
          parameter(formula, "aggregate_ratio", default: 0)
        ],
        dry_volume_factor: parameter(formula, "dry_volume_factor", default: BigDecimal("1.54"))
      ).call

      bag_volume_cft = parameter(formula, "cement_bag_volume_cft", default: BigDecimal("1.25"))
      raw_bags = bag_volume_cft.zero? ? BigDecimal("0") : mix.cement_volume_cft / bag_volume_cft
      purchase_bags = (raw_bags * (1 + @material.wastage_percentage / 100)).ceil
      rate = @material.rate_for(state: @state, city: @city)

      QuantityResult.new(
        category_code: "cement_#{@activity}",
        item_name: "#{@material.name} (#{@activity.humanize})",
        unit: @material.unit,
        raw_quantity: raw_bags.round(2),
        purchase_quantity: purchase_bags,
        rate: rate,
        amount: (purchase_bags * rate).round(2),
        data_source: :calculated
      )
    end
  end
end
