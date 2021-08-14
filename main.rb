%w[ http json ].each { |gem| require gem }

$url = 'https://store-site-backend-static-ipv4.ak.epicgames.com/freeGamesPromotions'

def request_get()
  request = HTTP.get($url)
  if request.code != 200
    puts "URL: " + $url
    puts "Request respone is not 200 code."
    return(nil)
  end
  return request
end

def parse(response)
  if response.nil? then 
    return nil
  end
  data = JSON.parse(response)
  data['data']['Catalog']['searchStore']['elements'].each do |key, obj|
    puts key["title"] unless key['promotions'].nil?
  end
end

def update_info()
  puts "Error." if not parse(request_get())
end

update_info()
exit(0)
