class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.integer :category_id

      t.timestamps null: false
    end

    create_table :categories_companies, id: false do |t|
    	t.belongs_to :category, index: true
    	t.belongs_to :company, index: true
    end
  end
end
