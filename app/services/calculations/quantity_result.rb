module Calculations
  # Uniform output for every material/labour quantity calculation service.
  QuantityResult = Struct.new(
    :category_code, :item_name, :unit, :raw_quantity, :purchase_quantity, :rate, :amount, :data_source,
    :floor_label, :item_type,
    keyword_init: true
  )
end
