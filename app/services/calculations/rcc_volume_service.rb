module Calculations
  # Pure geometric volume formulas for preliminary RCC component planning.
  # Column/footing sizes here are illustrative inputs, not approved structural sizes.
  module RccVolumeService
    module_function

    def column_volume_cft(width_in:, depth_in:, height_ft:, count:)
      (BigDecimal(width_in.to_s) / 12) * (BigDecimal(depth_in.to_s) / 12) * BigDecimal(height_ft.to_s) * count
    end

    def footing_volume_cft(length_ft:, width_ft:, depth_ft:, count:)
      BigDecimal(length_ft.to_s) * BigDecimal(width_ft.to_s) * BigDecimal(depth_ft.to_s) * count
    end

    def slab_volume_cft(area_sqft:, thickness_in:)
      BigDecimal(area_sqft.to_s) * (BigDecimal(thickness_in.to_s) / 12)
    end
  end
end
