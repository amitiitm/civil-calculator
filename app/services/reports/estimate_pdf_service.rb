module Reports
  # Renders a Bill of Quantities PDF for a single estimate using Prawn.
  class EstimatePdfService
    include ActionView::Helpers::NumberHelper

    def initialize(estimate)
      @estimate = estimate
    end

    def call
      Prawn::Document.new(page_size: "A4", margin: 36).tap do |pdf|
        header(pdf)
        summary(pdf)
        line_items_table(pdf)
        disclaimer(pdf)
      end
    end

    private

    attr_reader :estimate

    def header(pdf)
      pdf.text "BuildEstimate - Bill of Quantities", size: 18, style: :bold
      pdf.text "Project: #{estimate.project.name}"
      pdf.text "Client: #{estimate.project.client_name}" if estimate.project.client_name.present?
      pdf.text "Estimate v#{estimate.version_number} | Price date: #{estimate.price_date}"
      pdf.move_down 10
    end

    def summary(pdf)
      pdf.text "Total Estimated Cost: #{currency(estimate.total_cost)}", size: 14, style: :bold
      pdf.text "Material cost: #{currency(estimate.material_cost)} | Cost per sqft: #{currency(estimate.cost_per_sqft)}"
      pdf.move_down 10
    end

    def line_items_table(pdf)
      header_row = [ "Item", "Floor", "Unit", "Quantity", "Rate", "Amount", "Source" ]
      rows = estimate.estimate_line_items.order(:floor_label, :item_name).map do |li|
        [ li.item_name, li.floor_label, li.unit, li.purchase_quantity, li.rate, li.amount, li.data_source ]
      end

      pdf.table([ header_row ] + rows, header: true, width: pdf.bounds.width) do |table|
        table.row(0).font_style = :bold
        table.row(0).background_color = "F3F4F6"
      end
    end

    def disclaimer(pdf)
      pdf.move_down 16
      if estimate.assumptions_notes.present?
        pdf.text "Assumptions: #{estimate.assumptions_notes}", size: 8
      end
      pdf.text(
        "This is a preliminary construction estimate, not a substitute for structural engineering calculations, " \
        "approved architectural plans, soil testing, or certified quantity surveying. Column sizes, reinforcement, " \
        "and foundation design must be verified by a qualified structural engineer.",
        size: 8, style: :italic
      )
    end

    def currency(amount)
      "Rs. #{number_with_delimiter(amount.to_i)}"
    end
  end
end
