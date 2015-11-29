class CompanySerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :address, :telephone_number, :fax_number, :email, :website, :opening_hours, :errors
end
