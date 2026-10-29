module Calculations
  # Project-wide average door/window count and cost, based on BHK type - not
  # derived from individually modelled Room/Door/Window records. Useful for a
  # quick overall estimate before a full floor-wise layout is entered.
  #
  # Door cost is a flat average rate per door including the frame (chokhat).
  # Window cost is per sqft and depends on the selected window material.
  class DoorWindowAverageService
    DEFAULT_DOOR_COUNTS = {
      "bhk_1" => 5, "bhk_2" => 7, "bhk_3" => 9, "bhk_4" => 11, "custom_layout" => 7
    }.freeze

    DEFAULT_WINDOW_COUNTS = {
      "bhk_1" => 3, "bhk_2" => 5, "bhk_3" => 7, "bhk_4" => 9, "custom_layout" => 5
    }.freeze

    def initialize(bhk_type:, window_material: "aluminium")
      @bhk_type = bhk_type.to_s
      @window_material = window_material.to_s
    end

    def call
      [ door_result, window_result ]
    end

    private

    attr_reader :bhk_type, :window_material

    def door_result
      count = ConstructionSetting.fetch("avg_door_count_#{bhk_type}", DEFAULT_DOOR_COUNTS.fetch(bhk_type, 7)).to_i
      width_ft = ConstructionSetting.fetch("average_door_width_ft", 3.5)
      height_ft = ConstructionSetting.fetch("average_door_height_ft", 7)
      rate = ConstructionSetting.fetch("door_cost_with_chokhat", 7000)

      QuantityResult.new(
        category_code: "doors_average",
        item_name: "Doors (avg #{count} nos, #{width_ft}x#{height_ft} ft incl. chokhat)",
        unit: "nos",
        raw_quantity: count,
        purchase_quantity: count,
        rate: rate,
        amount: (count * rate).round(2),
        data_source: :assumed,
        floor_label: "Project Summary"
      )
    end

    def window_result
      count = ConstructionSetting.fetch("avg_window_count_#{bhk_type}", DEFAULT_WINDOW_COUNTS.fetch(bhk_type, 5)).to_i
      width_ft = ConstructionSetting.fetch("average_window_width_ft", 5)
      height_ft = ConstructionSetting.fetch("average_window_height_ft", 4)
      rate = ConstructionSetting.fetch("window_rate_#{window_material}_per_sqft", 250)

      total_area_sqft = (count * width_ft * height_ft).round(2)

      QuantityResult.new(
        category_code: "windows_average",
        item_name: "Windows (avg #{count} nos, #{width_ft}x#{height_ft} ft, #{window_material.humanize})",
        unit: "sqft",
        raw_quantity: total_area_sqft,
        purchase_quantity: total_area_sqft,
        rate: rate,
        amount: (total_area_sqft * rate).round(2),
        data_source: :assumed,
        floor_label: "Project Summary"
      )
    end
  end
end
