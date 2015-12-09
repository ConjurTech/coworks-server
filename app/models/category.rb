class Category < ActiveRecord::Base
  belongs_to :parent_category, class_name:"Category", foreign_key:'category_id'
  has_many :subcategories, class_name:"Category", dependent: :nullify
  has_and_belongs_to_many :companies
end
