%w[
  http
  json
  date
].each { |gem| require gem }

%w[
  eos_data
  promotions_parse
].each { |file| require_relative file }

url = 'https://store-site-backend-static-ipv4.ak.epicgames.com/freeGamesPromotions'
url_ru_param = '?locale=ru&country=RU&allowCountries=RU'

def update_info(url)
  puts 'Error.' unless parse(request(url))
end

update_info(url + url_ru_param)

exit(0)
