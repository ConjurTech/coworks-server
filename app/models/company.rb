class Company < ActiveRecord::Base
  attr_accessor :normalized_phone_number
  attr_accessor :normalized_fax_number

  has_attached_file :logo, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "https://placehold.it/300x300"
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/

  phony_normalize :phone_number, as: :normalized_phone_number, default_country_code: 'SG'
  phony_normalize :fax_number, as: :normalized_fax_number, default_country_code: 'SG'

  validates :normalized_phone_number, :normalized_fax_number, phony_plausible: true
  validates :email, email: true, allow_blank: true
  validates :website, url: true, allow_blank: true

  before_save :save_normalized_numbers

  # We only set the noramlized number on a attribute accessor,
  # so copy it to the actual record if validation was successful.
  def save_normalized_numbers
    self.phone_number = normalized_phone_number
    self.fax_number = normalized_fax_number
  end
end
