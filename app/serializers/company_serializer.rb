class CompanySerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :address, :phone_number, :fax_number, :email, :website, :opening_hours, :logo
end
