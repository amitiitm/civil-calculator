module Reports
  # Builds an Excel (.xlsx) Bill of Quantities export for a single estimate using caxlsx.
  class EstimateExcelService
    def initialize(estimate)
      @estimate = estimate
    end

    def call
      package = Axlsx::Package.new
      workbook = package.workbook

      workbook.add_worksheet(name: "BOQ") do |sheet|
        bold = workbook.styles.add_style(b: true, bg_color: "F3F4F6")
        currency = workbook.styles.add_style(format_code: "#,##0.00")

        sheet.add_row [ "BuildEstimate - Bill of Quantities" ]
        sheet.add_row [ "Project", estimate.project.name ]
        sheet.add_row [ "Estimate version", estimate.version_number ]
        sheet.add_row [ "Price date", estimate.price_date.to_s ]
        sheet.add_row []
        sheet.add_row [ "Item", "Floor", "Unit", "Quantity", "Rate", "Amount", "Source" ], style: bold

        estimate.estimate_line_items.order(:floor_label, :item_name).each do |li|
          sheet.add_row [
            li.item_name, li.floor_label, li.unit, li.purchase_quantity.to_f, li.rate.to_f, li.amount.to_f,
            li.data_source
          ], style: [ nil, nil, nil, nil, currency, currency, nil ]
        end

        sheet.add_row []
        sheet.add_row [ "Total cost", estimate.total_cost.to_f ], style: [ bold, currency ]
      end

      package
    end

    private

    attr_reader :estimate
  end
end
