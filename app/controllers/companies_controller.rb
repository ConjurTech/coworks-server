class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]

  # GET /companies
  def index
    @companies = Company.all

    render json: @companies
  end

  # GET /companies/1
  def show
    render json: @company
  end

  # POST /companies
  def create
    @company = Company.new(company_params)

    if @company.save
      render @company
    else
      render json: { errors: @company.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /companies/1
  def update
    if @company.update(company_params)
      render @company
    else
      render json: { errors: @company.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /companies/1
  def destroy
    if @company.destroy
      render @company
    else
      render json: { errors: @company.errors }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def company_params
    params.require(:company).permit(:name, :description, :address, :phone_number, :fax_number, :email, :website, :opening_hours)
  end
end
