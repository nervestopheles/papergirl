%w[
  http
  json
  date
].each { |gem| require gem }

require_relative 'eos_data'

url = 'https://store-site-backend-static-ipv4.ak.epicgames.com/freeGamesPromotions'
url_ru_param = '?locale=ru&country=RU&allowCountries=RU'

update_info(url + url_ru_param)

exit(0)
