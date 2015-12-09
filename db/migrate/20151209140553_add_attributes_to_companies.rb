class AddAttributesToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :facebook, :string
    add_column :companies, :staff_strength, :string
    add_column :companies, :payment_method, :string
    add_column :companies, :market_coverage, :string
  end
end
