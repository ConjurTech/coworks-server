require_relative 'scrapper'
require 'open-uri'

namespace :seeder do
  desc "Seed companies from yellowpages into db"
  task seed: :environment do
    Rails.logger.info "Start: " + Time.now.to_s
    parentCategoryURLs = getParentCategoryURLs()
    parentCategoryURLs.each do |parentCategoryURL|
      childCategoryURLS = getChildCategoryURLs(parentCategoryURL)
      childCategoryURLS.each do |childCategoryURL|
        categoryURLs = getCategoryURLs(childCategoryURL)
        categoryURLs.each do |categoryURL|
          companyURLs = getCompanyURLs(categoryURL)
          companyURLs.each do |companyURL|
            params = getCompany(companyURL)
            company = Company.new(params[:company])
            company.categories << params[:categories].map { |category| Category.find_or_create_by(name: category) }
            company.brands << params[:brands].map { |brand| Brand.find_or_create_by(name: brand) }
            company.tags << params[:tags].map { |tag| Tag.find_or_create_by(name: tag) }

            open(params[:logo_url]) { |f|
              company.logo = f
            }

            if !company.save
              Rails.logger.error "Failed to save " + companyURL
            end
          end
        end
      end
    end
    Rails.logger.info "End: " + Time.now.to_s
  end
end
