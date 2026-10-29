module Calculations
  # Orchestrates the Phase 1 material calculation engine for a project: exterior and
  # interior brickwork, RCC slab/column/footing concrete (cement/sand/aggregate/steel),
  # and rolls everything into a persisted Estimate with line items.
  #
  # Known Phase 1 simplification: wall adjacency between rooms is not modelled -
  # interior walls are derived from each room's own perimeter, so shared walls between
  # adjacent rooms are counted once per room rather than once overall.
  #
  # A partial top floor (e.g. the ".5" in a 2.5-floor project) is modelled via
  # ProjectFloor#footprint_percentage, scaling exterior wall perimeter, slab area,
  # and column count linearly - a shape-agnostic approximation, not exact geometry.
  #
  # Door/window counts, tile flooring, electrical points, and general labour are all
  # computed per floor from admin-configurable averages/rates rather than requiring
  # exact fixtures to be modelled - a staircase granite allowance is computed once
  # for the whole project (one flight per full floor, plus one for a partial floor).
  class CostEstimatorService
    Result = Struct.new(:success?, :estimate, :error, keyword_init: true)

    def initialize(project:, user:, construction_package: nil, state: nil, city: nil, column_count_per_floor: nil, window_material: "aluminium")
      @project = project
      @user = user
      @construction_package = construction_package
      @state = state || project.state
      @city = city || project.city
      @column_count_per_floor = column_count_per_floor || ConstructionSetting.fetch("default_column_count_per_floor", 4).to_i
      @window_material = window_material
    end

    def call
      estimate = nil

      ActiveRecord::Base.transaction do
        estimate = build_estimate
        line_items = project.project_floors.flat_map { |floor| line_items_for_floor(floor) }
        line_items += foundation_line_items(project.project_floors.order(:floor_number).first)
        line_items += staircase_line_items

        line_items.each { |result| estimate.estimate_line_items.create!(line_item_attributes(result)) }
        estimate.recalculate_totals!
      end

      Result.new(success?: true, estimate: estimate, error: nil)
    rescue Calculations::CalculationError, ActiveRecord::RecordInvalid => e
      Result.new(success?: false, estimate: nil, error: e.message)
    end

    private

    attr_reader :project, :user, :construction_package, :state, :city, :column_count_per_floor, :window_material

    def build_estimate
      next_version = project.estimates.maximum(:version_number).to_i + 1
      project.estimates.create!(
        user: user,
        construction_package: construction_package,
        version_number: next_version,
        status: :draft,
        price_date: Date.current,
        contingency_percentage: ConstructionSetting.fetch("default_contingency_percentage", 5)
      )
    end

    def line_items_for_floor(floor)
      [
        *exterior_wall_line_items(floor),
        *interior_wall_line_items(floor),
        *slab_line_items(floor),
        *column_line_items(floor),
        *flooring_line_items(floor),
        *electrical_line_items(floor),
        *labour_line_items(floor),
        *door_window_line_items(floor)
      ]
    end

    def exterior_wall_line_items(floor)
      thickness_in = ConstructionSetting.fetch("wall_thickness_external_in", 9)
      perimeter_ft = 2 * (project.construction_length_ft + project.construction_width_ft) * (floor.footprint_percentage / 100)
      opening_area = floor.doors.where(room_id: nil).sum(&:area_sqft) + floor.windows.where(room_id: nil).sum(&:area_sqft)

      wall_results(
        floor: floor, activity: "masonry", wall_length_ft: perimeter_ft, wall_height_ft: floor.floor_height_ft,
        wall_thickness_in: thickness_in, opening_area_sqft: opening_area, label: "Exterior wall"
      )
    end

    def interior_wall_line_items(floor)
      thickness_in = ConstructionSetting.fetch("wall_thickness_internal_in", 4.5)

      floor.rooms.flat_map do |room|
        opening_area = room.doors.sum(&:area_sqft) + room.windows.sum(&:area_sqft)
        wall_results(
          floor: floor, activity: "masonry", wall_length_ft: room.perimeter_ft, wall_height_ft: room.wall_height_ft,
          wall_thickness_in: thickness_in, opening_area_sqft: opening_area, label: "#{room.name} wall"
        )
      end
    end

    def wall_results(floor:, activity:, wall_length_ft:, wall_height_ft:, wall_thickness_in:, opening_area_sqft:, label:)
      brick = BrickQuantityService.new(
        material: material_for("bricks"), wall_length_ft: wall_length_ft, wall_height_ft: wall_height_ft,
        wall_thickness_in: wall_thickness_in, opening_area_sqft: opening_area_sqft, state: state, city: city
      ).call

      gross_volume_cft = wall_length_ft * wall_height_ft * (wall_thickness_in / 12)
      cement = CementQuantityService.new(material: material_for("cement"), activity: activity, wet_volume_cft: gross_volume_cft, state: state, city: city).call
      sand = SandQuantityService.new(material: material_for("sand"), activity: activity, wet_volume_cft: gross_volume_cft, state: state, city: city).call

      [ brick, cement, sand ].each { |r| r.item_name = "#{label} - #{r.item_name}" }
      tag_floor(floor, [ brick, cement, sand ])
    end

    def slab_line_items(floor)
      thickness_in = ConstructionSetting.fetch("slab_thickness_in", 5)
      volume_cft = RccVolumeService.slab_volume_cft(area_sqft: floor.footprint_sqft, thickness_in: thickness_in)

      concrete_results(activity: "rcc", element_type: "slab", volume_cft: volume_cft, label: "#{floor.name} slab", floor: floor)
    end

    def column_line_items(floor)
      width_in = ConstructionSetting.fetch("column_width_in", 9)
      depth_in = ConstructionSetting.fetch("column_depth_in", 9)
      floor_column_count = [ (column_count_per_floor * floor.footprint_percentage / 100).round, 1 ].max
      volume_cft = RccVolumeService.column_volume_cft(
        width_in: width_in, depth_in: depth_in, height_ft: floor.floor_height_ft, count: floor_column_count
      )

      concrete_results(activity: "rcc", element_type: "column", volume_cft: volume_cft, label: "#{floor.name} columns", floor: floor)
    end

    def foundation_line_items(ground_floor)
      return [] if ground_floor.nil?

      length_ft = ConstructionSetting.fetch("footing_length_ft", 4)
      width_ft = ConstructionSetting.fetch("footing_width_ft", 4)
      depth_ft = ConstructionSetting.fetch("footing_depth_ft", 3)
      volume_cft = RccVolumeService.footing_volume_cft(
        length_ft: length_ft, width_ft: width_ft, depth_ft: depth_ft, count: column_count_per_floor
      )

      concrete_results(activity: "rcc", element_type: "footing", volume_cft: volume_cft, label: "Foundation footings", floor: ground_floor)
    end

    def door_window_line_items(floor)
      return [] unless floor.uses_average_doors_windows?

      results = DoorWindowAverageService.new(bhk_type: floor.bhk_type, window_material: window_material).call
      tag_floor(floor, results)
    end

    def flooring_line_items(floor)
      tag_floor(floor, floor.rooms.map { |room| FlooringQuantityService.new(material: tile_material, room: room, state: state, city: city).call })
    end

    def electrical_line_items(floor)
      points = floor.rooms.sum(&:electrical_point_count)
      result = ElectricalQuantityService.new(material: material_for("electrical"), points: points, label: floor.name, state: state, city: city).call
      tag_floor(floor, [ result ].compact)
    end

    def labour_line_items(floor)
      result = LabourQuantityService.new(labour_rate: labour_rate_for("General Construction Labour"), area_sqft: floor.footprint_sqft, label: floor.name).call
      tag_floor(floor, [ result ])
    end

    def staircase_line_items
      flights = project.full_floors_count + (project.partial_top_floor? ? 1 : 0)
      result = StaircaseQuantityService.new(material: material_for("granite"), flights: flights, state: state, city: city).call
      [ result ].compact
    end

    def concrete_results(activity:, element_type:, volume_cft:, label:, floor:)
      cement = CementQuantityService.new(material: material_for("cement"), activity: activity, wet_volume_cft: volume_cft, state: state, city: city).call
      sand = SandQuantityService.new(material: material_for("sand"), activity: activity, wet_volume_cft: volume_cft, state: state, city: city).call
      aggregate = AggregateQuantityService.new(material: material_for("aggregate"), activity: activity, wet_volume_cft: volume_cft, state: state, city: city).call
      steel = SteelQuantityService.new(material: material_for("steel"), element_type: element_type, concrete_volume_cft: volume_cft, state: state, city: city).call

      [ cement, sand, aggregate, steel ].each { |r| r.item_name = "#{label} - #{r.item_name}" }
      tag_floor(floor, [ cement, sand, aggregate, steel ])
    end

    def tag_floor(floor, results)
      results.each { |r| r.floor_label = floor.name }
      results
    end

    def line_item_attributes(result)
      {
        material_category_name: result.category_code,
        item_name: result.item_name,
        unit: result.unit,
        raw_quantity: result.raw_quantity,
        purchase_quantity: result.purchase_quantity,
        rate: result.rate,
        item_type: result.item_type || :material,
        data_source: result.data_source,
        floor_label: result.floor_label,
        formula_identifier: result.category_code
      }
    end

    def material_for(category_code)
      MaterialCategory.find_by!(code: category_code).materials.active.first ||
        raise(Calculations::MissingFormulaParameterError, "No active material configured for category '#{category_code}'")
    end

    def tile_material
      MaterialCategory.find_by!(code: "tiles").materials.active.find_by(quality_grade: project.construction_quality) ||
        raise(Calculations::MissingFormulaParameterError, "No active tile material configured for quality grade '#{project.construction_quality}'")
    end

    def labour_rate_for(work_type)
      LabourRate.active.find_by(work_type: work_type) ||
        raise(Calculations::MissingFormulaParameterError, "No active labour rate configured for '#{work_type}'")
    end
  end
end
