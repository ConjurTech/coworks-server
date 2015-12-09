class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name

      t.timestamps null: false
    end

    create_table :companies_tags, id: false do |t|
    	t.belongs_to :company, index: true
    	t.belongs_to :tag, index: true
    end
  end
end
