module Calculations
  # Net masonry volume = gross wall volume - door/window opening volume
  # Brick quantity = net masonry volume / effective volume per brick, plus wastage
  class BrickQuantityService
    include FormulaLookup

    CATEGORY_CODE = "bricks".freeze

    def initialize(material:, wall_length_ft:, wall_height_ft:, wall_thickness_in:, opening_area_sqft: 0, state: nil, city: nil)
      @material = material
      @wall_length_ft = BigDecimal(wall_length_ft.to_s)
      @wall_height_ft = BigDecimal(wall_height_ft.to_s)
      @wall_thickness_ft = BigDecimal(wall_thickness_in.to_s) / 12
      @opening_area_sqft = BigDecimal(opening_area_sqft.to_s)
      @state = state
      @city = city
    end

    def call
      formula = formula_for(CATEGORY_CODE)
      brick_length_in = parameter(formula, "brick_length_in")
      brick_width_in = parameter(formula, "brick_width_in")
      brick_height_in = parameter(formula, "brick_height_in")
      mortar_thickness_in = parameter(formula, "mortar_thickness_in")

      gross_volume_cft = @wall_length_ft * @wall_height_ft * @wall_thickness_ft
      opening_volume_cft = @opening_area_sqft * @wall_thickness_ft
      net_volume_cft = [ gross_volume_cft - opening_volume_cft, BigDecimal("0") ].max

      effective_brick_volume_cft = ((brick_length_in + mortar_thickness_in) / 12) *
                                    ((brick_width_in + mortar_thickness_in) / 12) *
                                    ((brick_height_in + mortar_thickness_in) / 12)

      raw_quantity = effective_brick_volume_cft.zero? ? BigDecimal("0") : net_volume_cft / effective_brick_volume_cft
      purchase_quantity = (raw_quantity * (1 + @material.wastage_percentage / 100)).ceil
      rate = @material.rate_for(state: @state, city: @city)

      QuantityResult.new(
        category_code: CATEGORY_CODE,
        item_name: @material.name,
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
