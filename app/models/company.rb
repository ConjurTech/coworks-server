class Company < ActiveRecord::Base
  has_attached_file :logo, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "https://placehold.it/300x300"
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/

  phony_normalize :phone_number, :fax_number, default_country_code: 'SG'

  validates :phone_number, :fax_number, phony_plausible: true
  validates :email, email: true, allow_blank: true
  validates :website, url: true, allow_blank: true
end
