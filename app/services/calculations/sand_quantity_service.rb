module Calculations
  # Sand quantity for the given activity's configured mix ratio (brickwork mortar,
  # plaster, concrete, floor bedding, etc).
  class SandQuantityService
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

      raw_quantity = mix.sand_volume_cft
      purchase_quantity = (raw_quantity * (1 + @material.wastage_percentage / 100)).round(2)
      rate = @material.rate_for(state: @state, city: @city)

      QuantityResult.new(
        category_code: "sand_#{@activity}",
        item_name: "#{@material.name} (#{@activity.humanize})",
        unit: @material.unit,
        raw_quantity: raw_quantity.round(2),
        purchase_quantity: purchase_quantity,
        rate: rate,
        amount: (purchase_quantity * rate).round(2),
        data_source: :calculated
      )
    end
  end
end
