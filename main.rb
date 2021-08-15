%w[http json].each { |gem| require gem }

url = 'https://store-site-backend-static-ipv4.ak.epicgames.com/freeGamesPromotions'
url_ru_param = '?locale=ru&country=RU&allowCountries=RU'

def request_get(url)
  request = HTTP.get(url)
  if request.code != 200
    puts 'URL: ' + url
    puts 'Request respone is not 200 code.'
    return(nil)
  end
  request
end

def parse(response)
  return nil if response.nil?

  data = JSON.parse(response)
  data['data']['Catalog']['searchStore']['elements'].each do |key, _obj|
    next if key['promotions'].nil?

    project_name = key['title']
    effective_date = key['effectiveDate']

    puts project_name
    puts effective_date
  end
end

def update_info(url)
  puts 'Error.' unless parse(request_get(url))
end

update_info(url + url_ru_param)
exit(0)
