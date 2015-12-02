require 'json'
require 'nokogiri'
require 'open-uri'
require 'CGI'

@baseURL = 'http://www.yellowpages.com.sg'

def getParentCategoryURLs()
	doc = Nokogiri::HTML(open(@baseURL))
	return doc.css('a.use-ajax').map { |a| a['href'] }
end

def getChildCategoryURLs(relativeURL)
	json = JSON.parse(open(@baseURL + relativeURL).read)
	doc = Nokogiri::HTML(json[1]['data'])
	return doc.css('a.use-ajax').map { |a| a['href'] }
end

def getCategoryURLs(relativeURL)
	json = JSON.parse(open(@baseURL + relativeURL).read)
	doc = Nokogiri::HTML(json[1]['data'])
	return doc.css('a:not(.use-ajax)').map { |a| a['href'] }
end

# Returns all the company urls
def getCompanyURLs(relativeURL)
	doc = Nokogiri::HTML(open(@baseURL + relativeURL))
	return doc.css('div.left.company_info a:not([onclick])').map { |a| a['href'] }
end

# currently available fields if it exists
# name
# subname
# address
# logo
# facebook
# telephone
# fax
# email
# website
# catalogue link
# categories
# main contact
# designation
# staff strength
# email
# websites
# tel
# payment method
# market coverage
# opening hours
# product & services
# display ad
# catalogue
# listings
def getCompanyInfo(url)
	doc = Nokogiri::HTML(open(url))
	article = doc.css('article.company_detail')

	# top details

	topDiv =  article.css('div.top_company_detail')

	nameDiv = topDiv.css('div.com_name')
	name = nameDiv.css('h2').text
	subName = nameDiv.css('p').text
	logo = nameDiv.css('a img').first['src']
	address = topDiv.css('div.row.com_address p span').text
	puts name, subName, logo, address

	a = topDiv.css('div.com_social a').first
	if a != nil
		facebook = a['href']
		puts facebook
	end

	infoDiv = topDiv.css('div.row.com_info div').first
	elements = infoDiv.elements
	i = 0
	while i < elements.length do
		lbl = elements[i].css('label').text.strip
		case lbl
		when "Telephone :", "Fax :"
			data = elements[i=i+1]
			data = data.css('> text()').text.strip + data['data-last'].strip
		when "Email :"
			dataCfEmail = elements[i].css('span.__cf_email__').first['data-cfemail']
			data = getEmail(dataCfEmail)
		when "Website:"
			data = elements[i].css('a').text
		when "Catalogue Link :"
			data = elements[i].css('a.com_catelogue').first['href']
		else
			STDERR.puts "label: " + lbl
		end
		i += 1
		
		puts lbl
		puts data
	end

	categories = []
	elements = topDiv.css('div div.line_share_social p.row.com_cat a')
	elements.each do |element|
		categories.push(element.text)
	end
	puts 'Categories: ', categories

	textNodes = topDiv.css('div div.left.com_description text()')
	description = textNodes.map {|textNode| textNode.text.strip }.join("\n")
	puts description

	paragraphs = topDiv.css('div div.com_person_contact p')
	paragraphs.each do |paragraph|
		lbl = paragraph.css('label').text.strip
		case lbl
		when "Main Contact :", "Designation :", "Websites :", "Tel :", "Payment Method :", "Market Coverage :", "Opening hours :", "Staff Strength :", "Year Established :"
			textNodes = paragraph.css('span text()')
			data = textNodes.map {|textNode| textNode.text.strip }.join("\n")
		when "Email :"
			dataCfEmail = paragraph.css('a.__cf_email__').first['data-cfemail']
			data = getEmail(dataCfEmail)
		else
			STDERR.puts "label: " + lbl
		end
		puts lbl, data
	end

	# middle details

	middleDiv = article.css('div.company_detail_middle')

	products = middleDiv.css('#product div a').map {|a| a['title']}
	puts 'Products: ', products

	displayAd = middleDiv.css('#iframeDisplayAd').first['src']
	puts displayAd

	iframe = middleDiv.css('#catalogue div.company_tab_content iframe').first
	if iframe != nil
		catalogue = iframe['src']
		puts catalogue
	end

	# listingName = middleDiv.css('#comp_detail_all_listing p').text
	# middleDiv.css('#comp_detail_all_listing div').each do|listingDiv| {
	# 	divs = listingDiv.css('div div')
	# }
end

def getEmail(a)
	email = ''
	r = Integer(a[0...2], 16)
	n = 2
	while a.length - n > 0 do
		i = Integer(a[n...(n+2)], 16)^r
		email += i.chr
		n += 2
	end
	return email
end

# puts getParentCategoryURLs()
# puts getChildCategoryURLs('/list_category/9236/0')
# puts getCategoryURLs('/list_category/9237/0')
# puts getCompanyURLs('/category/livestock-dealers')
# getCompanyInfo('http://www.yellowpages.com.sg/company/menara-freight-consolidators-m-sdn-bhd')
# getCompanyInfo('http://www.yellowpages.com.sg/company/v8-environmental-pte-ltd')
# getCompanyInfo('http://www.yellowpages.com.sg/company/lj-investigation-consultancy-services-pte-ltd')
# getCompanyInfo('http://www.yellowpages.com.sg/company/chun-hoe-trading-sdn-bhd')

# parentCategoryURLs = getParentCategoryURLs()
# parentCategoryURLs[0...3].each do |parentCategoryURL|
# 	childCategoryURLS = getChildCategoryURLs(parentCategoryURL)
# 	childCategoryURLS[0...3].each do |childCategoryURL|
# 		categoryURLs = getCategoryURLs(childCategoryURL)
# 		categoryURLs[0...3].each do |categoryURL|
# 			companyURLs = getCompanyURLs(categoryURL)
# 			companyURLs[0...3].each do |companyURL|
# 				getCompanyInfo(companyURL)
# 			end
# 		end
# 	end
# end
