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
# year established
# opening hours
# product & services
# display ad
# catalogue
# listings
def getCompanyInfo(url)
	company = {}

	doc = Nokogiri::HTML(open(url))
	article = doc.css('article.company_detail')

	# top details

	topDiv =  article.css('div.top_company_detail')

	nameDiv = topDiv.css('div.com_name')
	company["name"] = nameDiv.css('h2').text.strip
	subName = nameDiv.css('p').text.strip
	company["logo"] = nameDiv.css('a img').first['src'].strip
	company["address"] = topDiv.css('div.row.com_address p span').text

	a = topDiv.css('div.com_social a').first
	if a != nil
		company["facebook"] = a['href'].strip
	end

	infoDiv = topDiv.css('div.row.com_info div').first
	elements = infoDiv.elements
	i = 0
	while i < elements.length do
		lbl = elements[i].css('label').text.strip
		case lbl
		when "Telephone :"
			data = elements[i=i+1]
			company["telephone_number"] = data.css('> text()').text.strip + data['data-last'].strip
		when "Fax :"
			data = elements[i=i+1]
			company["fax_number"] = data.css('> text()').text.strip + data['data-last'].strip
		when "Email :"
			dataCfEmail = elements[i].css('span.__cf_email__').first['data-cfemail']
			company["email"] = getEmail(dataCfEmail)
		when "Website:"
			company["website"] = elements[i].css('a').text.strip
		when "Catalogue Link :"
			data = elements[i].css('a.com_catalogue').first['href']
		else
			STDERR.puts "label: " + lbl
		end
		i += 1
	end

	categories = []
	elements = topDiv.css('div div.line_share_social p.row.com_cat a')
	elements.each do |element|
		categories.push(element.text)
	end
	company["categories"] = categories

	textNodes = topDiv.css('div div.left.com_description text()')
	description = textNodes.map {|textNode| textNode.text.strip }.join("\n")
	company["description"] = description

	paragraphs = topDiv.css('div div.com_person_contact p')
	paragraphs.each do |paragraph|
		lbl = paragraph.css('label').text.strip
		case lbl
		when "Main Contact :",
			"Designation :",
			"Websites :",
			"Tel :",
			"Year Established :"
			textNodes = paragraph.css('span text()')
			data = textNodes.map {|textNode| textNode.text.strip }.join("\n")
		when "Payment Method :"
			textNodes = paragraph.css('span text()')
			company["payment_method"] = textNodes.map {|textNode| textNode.text.strip }.join("\n")
		when "Staff Strength :"
			textNodes = paragraph.css('span text()')
			company["staff_strength"] = textNodes.map {|textNode| textNode.text.strip }.join("\n")
		when "Market Coverage :"
			textNodes = paragraph.css('span text()')
			company["market_coverage"] = textNodes.map {|textNode| textNode.text.strip }.join("\n")
		when "Opening hours :"
			textNodes = paragraph.css('span text()')
			company["opening_hours"] = textNodes.map {|textNode| textNode.text.strip }.join("\n")
		when "Email :"
			dataCfEmail = paragraph.css('a.__cf_email__').first['data-cfemail']
			data = getEmail(dataCfEmail)
		else
			STDERR.puts "label: " + lbl
		end
	end

	# middle details

	middleDiv = article.css('div.company_detail_middle')

	products = middleDiv.css('#product div a').map {|a| a['title']}

	company["brands"] = middleDiv.css('#brands div a').map {|a| a['title']}

	displayAd = middleDiv.css('#iframeDisplayAd').first['src']

	iframe = middleDiv.css('#catalogue div.company_tab_content iframe').first
	if iframe != nil
		catalogue = iframe['src']
		puts catalogue
	end

	# listingName = middleDiv.css('#comp_detail_all_listing p').text
	# middleDiv.css('#comp_detail_all_listing div').each do|listingDiv| {
	# 	divs = listingDiv.css('div div')
	# }

	return company
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

company = getCompanyInfo("http://www.yellowpages.com.sg/company/komoco-motors-pte-ltd")
puts company.to_json
uri = URI('http://localhost:3000/companies.json')
req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' =>'application/json'})
req.body = company.to_json
res = Net::HTTP.start(uri.hostname, uri.port) do |http|
  http.request(req)
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
