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

    puts format_hash(key)
    print "\n"
  end
end

def format_hash(hash)
  data = {}

  data['title'] = hash['title']
  data['effectiveDate'] = hash['effectiveDate']

  unless hash['promotions']['promotionalOffers'] == []
    hash['promotions']['promotionalOffers'].each do |key, _obj|
      data['start_date'] = key['promotionalOffers'][0]['startDate']
      data['end_date'] = key['promotionalOffers'][0]['endDate']
    end
  end

  unless hash['promotions']['upcomingPromotionalOffers'] == []
    hash['promotions']['upcomingPromotionalOffers'].each do |key, _obj|
      data['start_date'] = key['promotionalOffers'][0]['startDate']
      data['end_date'] = key['promotionalOffers'][0]['endDate']
    end
  end

  return data
end

def update_info(url)
  puts 'Error.' unless parse(request_get(url))
end
