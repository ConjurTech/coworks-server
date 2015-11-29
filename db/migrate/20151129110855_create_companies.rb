class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.text :description
      t.string :address
      t.string :telephone_number
      t.string :fax_number
      t.string :email
      t.string :website
      t.string :opening_hours

      t.timestamps null: false
    end
  end
end
