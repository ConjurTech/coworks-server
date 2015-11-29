class RenameCompanyTelephoneToPhone < ActiveRecord::Migration
  def change
    rename_column :companies, :telephone_number, :phone_number
  end
end
