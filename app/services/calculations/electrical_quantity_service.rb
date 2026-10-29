module Calculations
  # Electrical allowance per room, billed per electrical point (switches, sockets,
  # wiring, basic fittings) using a single admin-configurable all-inclusive rate
  # rather than itemising every component - a deliberate Phase 1 simplification.
  class ElectricalQuantityService
    def initialize(material:, points:, label:, state: nil, city: nil)
      @material = material
      @points = points
      @label = label
      @state = state
      @city = city
    end

    def call
      return if points.to_i.zero?

      rate = material.rate_for(state: state, city: city)

      QuantityResult.new(
        category_code: "electrical",
        item_name: "#{label} - Electrical (wiring, switches, points: #{points})",
        unit: "point",
        raw_quantity: points,
        purchase_quantity: points,
        rate: rate,
        amount: (points * rate).round(2),
        data_source: :assumed,
        item_type: :material
      )
    end

    private

    attr_reader :material, :points, :label, :state, :city
  end
end
