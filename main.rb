#!/usr/bin/env ruby

%w[
  http
  json
  date
].each { |gem| require gem }

%w[
  fgd
].each { |file| require_relative file }

url = 'https://store-site-backend-static-ipv4.ak.epicgames.com/freeGamesPromotions'
url_ru_param = '?locale=ru&country=RU&allowCountries=RU'

info = FreeGamesData.new(url + url_ru_param)
puts JSON.pretty_generate(info.get)

exit(0)
