class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :name

      t.timestamps null: false
    end

    create_table :brands_companies, id: false do |t|
    	t.belongs_to :brand, index: true
    	t.belongs_to :company, index: true
    end
  end
end
