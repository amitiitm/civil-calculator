module Calculations
  # Shared dry-volume mix engine used by cement, sand, and aggregate calculations
  # so no single fixed consumption rate is reused across unrelated construction activities.
  class MixQuantityService
    MixResult = Struct.new(:cement_volume_cft, :sand_volume_cft, :aggregate_volume_cft, keyword_init: true)

    def initialize(wet_volume_cft:, mix_ratio:, dry_volume_factor:)
      @wet_volume_cft = BigDecimal(wet_volume_cft.to_s)
      @mix_ratio = mix_ratio.map { |part| BigDecimal(part.to_s) }
      @dry_volume_factor = BigDecimal(dry_volume_factor.to_s)
    end

    def call
      dry_volume_cft = @wet_volume_cft * @dry_volume_factor
      total_parts = @mix_ratio.sum
      cement_part, sand_part, aggregate_part = @mix_ratio

      MixResult.new(
        cement_volume_cft: volume_for(dry_volume_cft, cement_part, total_parts),
        sand_volume_cft: volume_for(dry_volume_cft, sand_part, total_parts),
        aggregate_volume_cft: volume_for(dry_volume_cft, aggregate_part, total_parts)
      )
    end

    private

    def volume_for(dry_volume_cft, part, total_parts)
      return BigDecimal("0") if part.nil? || part.zero? || total_parts.zero?

      dry_volume_cft * part / total_parts
    end
  end
end
