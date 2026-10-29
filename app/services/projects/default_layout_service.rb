module Projects
  # Generates a starter set of floors and rooms from a project's floor count and
  # BHK selection, so a project can be created with minimal input and still have
  # enough geometry for the cost estimator to run. Everything created here is a
  # regular ProjectFloor/Room record - freely editable afterwards in Floors & Rooms.
  #
  # A partial top floor (the ".5" in e.g. 2.5 floors) gets a smaller BHK layout,
  # one tier down from the project's main BHK type, and a 50% footprint share.
  class DefaultLayoutService
    FLOOR_ORDINAL_NAMES = %w[Ground First Second Third Fourth Fifth Sixth Seventh Eighth Ninth].freeze

    ROOM_SIZES_FT = {
      bedroom: [ 12, 10 ], master_bedroom: [ 14, 12 ], living_room: [ 15, 12 ], kitchen: [ 10, 10 ],
      bathroom: [ 8, 6 ], toilet: [ 6, 4 ], dining_room: [ 10, 10 ], store_room: [ 6, 6 ], balcony: [ 10, 4 ]
    }.freeze

    BHK_ROOM_LAYOUTS = {
      "bhk_1" => %i[living_room kitchen bedroom bathroom],
      "bhk_2" => %i[living_room kitchen master_bedroom bedroom bathroom bathroom],
      "bhk_3" => %i[living_room kitchen master_bedroom bedroom bedroom bathroom bathroom dining_room],
      "bhk_4" => %i[living_room kitchen master_bedroom bedroom bedroom bedroom bathroom bathroom bathroom dining_room]
    }.freeze

    # BHK tier used for a partial top floor, one notch below the project's main BHK.
    DOWNGRADED_BHK = { "bhk_4" => "bhk_3", "bhk_3" => "bhk_2", "bhk_2" => "bhk_1", "bhk_1" => "bhk_1" }.freeze

    DEFAULT_WALL_HEIGHT_FT = 10

    def initialize(project)
      @project = project
    end

    def call
      return if project.bhk_type == "custom_layout"
      return if project.project_floors.exists?

      ActiveRecord::Base.transaction do
        (1..project.full_floors_count).each { |floor_number| build_floor(floor_number, project.bhk_type) }

        if project.partial_top_floor?
          build_floor(
            project.full_floors_count + 1, DOWNGRADED_BHK.fetch(project.bhk_type, project.bhk_type),
            footprint_percentage: 50, partial: true
          )
        end
      end
    end

    private

    attr_reader :project

    def build_floor(floor_number, bhk_type, footprint_percentage: 100, partial: false)
      name = FLOOR_ORDINAL_NAMES[floor_number - 1] || "Floor #{floor_number}"
      name = "#{name} Floor#{partial ? ' (Partial)' : ''}"

      floor = project.project_floors.create!(
        floor_number: floor_number, name: name, floor_height_ft: DEFAULT_WALL_HEIGHT_FT,
        footprint_percentage: footprint_percentage, bhk_type: bhk_type
      )

      BHK_ROOM_LAYOUTS.fetch(bhk_type, []).each { |room_type| build_room(floor, room_type) }
      floor
    end

    def build_room(floor, room_type)
      length_ft, width_ft = ROOM_SIZES_FT.fetch(room_type)

      floor.rooms.create!(
        room_type: room_type, name: room_type.to_s.humanize, length_ft: length_ft, width_ft: width_ft,
        wall_height_ft: floor.floor_height_ft
      )
    end
  end
end
