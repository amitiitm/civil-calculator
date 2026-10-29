class EstimatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_estimate, only: [ :show, :destroy ]

  def index
    @estimates = authorize(@project.estimates.order(version_number: :desc))
  end

  def show
    authorize @estimate
    @line_items_by_floor = @estimate.estimate_line_items.group_by(&:floor_label)
    @overall_summary = overall_summary_for(@estimate)

    respond_to do |format|
      format.html
      format.pdf do
        pdf = Reports::EstimatePdfService.new(@estimate).call
        send_data pdf.render, filename: "estimate-#{@estimate.id}-v#{@estimate.version_number}.pdf",
                               type: "application/pdf", disposition: "inline"
      end
      format.xlsx do
        package = Reports::EstimateExcelService.new(@estimate).call
        send_data package.to_stream.read, filename: "estimate-#{@estimate.id}-v#{@estimate.version_number}.xlsx"
      end
    end
  end

  def create
    authorize @project.estimates.build

    package = ConstructionPackage.find_by(slug: params[:construction_package])
    result = Calculations::CostEstimatorService.new(
      project: @project, user: current_user, construction_package: package,
      window_material: params[:window_material].presence || "aluminium"
    ).call

    if result.success?
      redirect_to project_estimate_path(@project, result.estimate), notice: "Estimate generated."
    else
      redirect_to @project, alert: "Could not generate estimate: #{result.error}"
    end
  end

  def destroy
    authorize @estimate
    @estimate.destroy
    redirect_to project_estimates_path(@project), notice: "Estimate deleted."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_estimate
    @estimate = @project.estimates.find(params[:id])
  end

  # Rolls every line item up to its base material (cement, sand, bricks, doors, ...)
  # regardless of which floor or activity (masonry/rcc) produced it.
  def overall_summary_for(estimate)
    estimate.estimate_line_items.group_by(&:base_category).transform_values do |items|
      { unit: items.first.unit, quantity: items.sum(&:purchase_quantity), amount: items.sum(&:amount) }
    end
  end
end
