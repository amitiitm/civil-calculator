module Calculations
  # Preliminary steel estimation using a configurable kg-per-cft-of-concrete factor,
  # per structural element type. Always flagged as an assumption until a bar bending
  # schedule or structural drawings are supplied.
  class SteelQuantityService
    include FormulaLookup

    def initialize(material:, element_type:, concrete_volume_cft:, state: nil, city: nil)
      @material = material
      @element_type = element_type.to_s
      @concrete_volume_cft = BigDecimal(concrete_volume_cft.to_s)
      @state = state
      @city = city
    end

    def call
      formula = formula_for("steel_#{@element_type}")
      kg_per_cft = parameter(formula, "kg_per_cft")

      raw_kg = @concrete_volume_cft * kg_per_cft
      purchase_kg = (raw_kg * (1 + @material.wastage_percentage / 100)).round(2)
      rate = @material.rate_for(state: @state, city: @city)

      QuantityResult.new(
        category_code: "steel_#{@element_type}",
        item_name: "#{@material.name} (#{@element_type.humanize})",
        unit: @material.unit,
        raw_quantity: raw_kg.round(2),
        purchase_quantity: purchase_kg,
        rate: rate,
        amount: (purchase_kg * rate).round(2),
        data_source: :assumed
      )
    end
  end
end
