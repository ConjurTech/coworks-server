require 'json'
require 'nokogiri'
require 'open-uri'

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

def getCompanyInfo(url)
	doc = Nokogiri::HTML(open(url))
	div = doc.css('article.company_detail div.top_company_detail')
	name = div.css('div.com_name h2').text
	address = div.css('div.row.com_address p span').text
	puts name, address

	# email is masked. not sure how resolve this now.
	infoDiv = div.css('div.row.com_info div').first
	elements = infoDiv.elements
	i = 0
	while i < elements.length do
		lbl = elements[i].css('label').text
		if lbl.start_with?('Telephone')
			data = elements[i=i+1]
			data = data.css('> text()').text.strip + data['data-last'].strip
		elsif lbl.start_with?('Fax')
			data = elements[i=i+1]
			data = data.css('> text()').text.strip + data['data-last'].strip
		elsif lbl.start_with?('Email')
			a = elements[i].css('span.__cf_email__').first['data-cfemail']
			data = ''
			r = Integer(a[0...2], 16)
			n = 2
			while a.length - n > 0 do
				i = Integer(a[n...(n+2)], 16)^r
				data += i.chr
				n += 2
			end
		elsif lbl.start_with?('Website')
			data = elements[i].css('a').text
		end
		i += 1
		
		puts lbl
		puts data
	end

	categories = []
	elements = div.css('div div.line_share_social p.row.com_cat a')
	elements.each do |element|
		categories.push(element.text)
	end
	puts 'Categories: ', categories

	paragraphs = div.css('div div.person_contact div p')
	paragraphs.each do |paragraph|
		lbl = paragraph.css('label').text
		span = paragraph.css('span text()')
		puts lbl, span
	end
end

# puts getParentCategoryURLs()
# puts getChildCategoryURLs('/list_category/9236/0')
# puts getCategoryURLs('/list_category/9237/0')
# puts getCompanyURLs('/category/livestock-dealers')
# getCompanyInfo('http://www.yellowpages.com.sg/company/menara-freight-consolidators-m-sdn-bhd')
getCompanyInfo('http://www.yellowpages.com.sg/company/v8-environmental-pte-ltd')