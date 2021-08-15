def request(url)
  response = HTTP.get(url)
  if response.code != 200
    puts 'URL: ' + url
    puts 'Request respone is not 200 code.'
    return nil
  end
  return response
end

def parse(response)
  return nil if response.nil?

  data = JSON.parse(response)
  data['data']['Catalog']['searchStore']['elements'].each do |key, _obj|
    next if key['promotions'].nil?

    puts JSON.pretty_generate(serialization(key))
  end
end

def serialization(data)
  obj = {}
  obj['title'] = data['title']
  obj['effectiveDate'] = data['effectiveDate']

  promotions_parse(data, obj)

  return obj
end
