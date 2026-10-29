module Calculations
  # Preliminary staircase granite allowance for the whole project: a flight of
  # stairs is needed for every full floor and for a partial top floor (the floor
  # height doesn't shrink just because the footprint does).
  class StaircaseQuantityService
    SQINCH_PER_SQFT = 144

    def initialize(material:, flights:, state: nil, city: nil)
      @material = material
      @flights = flights
      @state = state
      @city = city
    end

    def call
      return if flights.to_i.zero?

      steps_per_flight = ConstructionSetting.fetch("stair_steps_per_floor", 19).to_i
      sqinch_per_step = ConstructionSetting.fetch("stair_granite_sqinch_per_step", 800)
      total_steps = steps_per_flight * flights
      total_sqft = (total_steps * sqinch_per_step / SQINCH_PER_SQFT).round(2)

      rate = material.rate_for(state: state, city: city)

      QuantityResult.new(
        category_code: "granite_stairs",
        item_name: "Staircase granite (#{total_steps} steps across #{flights} flight#{'s' if flights != 1})",
        unit: "sqft",
        raw_quantity: total_sqft,
        purchase_quantity: total_sqft,
        rate: rate,
        amount: (total_sqft * rate).round(2),
        data_source: :assumed,
        item_type: :material,
        floor_label: "Staircases"
      )
    end

    private

    attr_reader :material, :flights, :state, :city
  end
end
