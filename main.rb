#!/usr/bin/env ruby

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

info = parse(request(url + url_ru_param))
if info.nil?
  puts 'Error.'
  exit(1)
end

puts JSON.pretty_generate(info)

exit(0)
