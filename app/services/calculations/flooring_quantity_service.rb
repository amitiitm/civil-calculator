module Calculations
  # Tile flooring area for a single room, using flat admin-configurable allowances
  # rather than precise tile-laying geometry:
  # - Washrooms (bathroom/toilet) get a flat sqft allowance (covers floor + wall tiling).
  # - Every other room is billed at a multiplier of its carpet area (covers wastage/cutting).
  class FlooringQuantityService
    def initialize(material:, room:, state: nil, city: nil)
      @material = material
      @room = room
      @state = state
      @city = city
    end

    def call
      area_sqft = if washroom?
        ConstructionSetting.fetch("washroom_tile_allowance_sqft", 250)
      else
        room.area_sqft * ConstructionSetting.fetch("tile_area_multiplier_other_rooms", 1.2)
      end

      rate = material.rate_for(state: state, city: city)

      QuantityResult.new(
        category_code: "tiles",
        item_name: "#{room.name} tiles",
        unit: "sqft",
        raw_quantity: area_sqft.round(2),
        purchase_quantity: area_sqft.round(2),
        rate: rate,
        amount: (area_sqft * rate).round(2),
        data_source: :assumed,
        item_type: :material
      )
    end

    private

    attr_reader :material, :room, :state, :city

    def washroom?
      room.bathroom? || room.toilet?
    end
  end
end
