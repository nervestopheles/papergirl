#!/usr/bin/env ruby

%w[
  json
  dotenv
  discordrb
].each { |gem| require gem }

%w[
  freegame
  newspaper
].each { |gem| require_relative gem }

Dotenv.load

url = 'https://store-site-backend-static-ipv4.ak.epicgames.com/freeGamesPromotions'
url_ru_param = '?locale=ru&country=RU&allowCountries=RU'

raw_output_file = 'raw_output.json'

informations = FreeGamesData.new(url + url_ru_param)
newsgirl = Discordrb::Commands::CommandBot.new token: ENV['TOKEN'], prefix: '!'

newsgirl.command(:sayonara, help_available: false) do |event|
  break unless event.user.id.to_s == ENV['ONIICHAN']

  newsgirl.send_message(event.channel.id, 'Sayonara.')
  exit 0
end

# У обычных серверов discord ограничение 2000 символов на сообщение.
# У серверов с nitro ограничение 4000 символов на сообщение.
newsgirl.command(:raw) do |event|
  event.respond 'Raw response:'
  event.respond format('%.1800s', informations.raw_data.to_s + '...')
  File.open(raw_output_file, 'w') do |file|
    file.write(JSON.pretty_generate(informations.raw_data))
  end
  return nil
end

newsgirl.command(:update) do |event|
  event.respond 'loading...'
  informations.update
  informations.data.each do |key, _obj|
    event.respond JSON.pretty_generate(key)
    event.respond 'Response length: ' + key.to_s.length.to_s
  end
  return nil
end

newsgirl.command(:free) do |event|
  event.respond 'Бесплатные игры на этой неделе:'
  informations.data.each do |info, _obj|
    next if info['price']['discountPrice'] != 0

    newspaper = Newspaper.new(info)
    event.channel.send_embed('', newspaper.newspaper)
  end
  return nil
end

newsgirl.run
