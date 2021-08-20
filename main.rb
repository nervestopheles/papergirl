#!/usr/bin/env ruby

%w[
  dotenv
  discordrb
].each { |gem| require gem }

%w[
  fgd
].each { |gem| require_relative gem }

Dotenv.load

url = 'https://store-site-backend-static-ipv4.ak.epicgames.com/freeGamesPromotions'
url_ru_param = '?locale=ru&country=RU&allowCountries=RU'

ru_info = FreeGamesData.new(url + url_ru_param)

newsgirl = Discordrb::Commands::CommandBot.new token: ENV['TOKEN'], prefix: '!'

mes = Discordrb::Webhooks::Embed.new
mes.title = 'Title!'

newsgirl.command(:sayonara, help_available: false) do |event|
  break unless event.user.id.to_s == ENV['ONIICHAN']

  newsgirl.send_message(event.channel.id, 'Sayonara.')
  exit 0
end

# У обычных серверов discord ограничение 2000 символов на сообщение.
# У серверов с nitro ограничение 4000 символов на сообщение.
newsgirl.command(:raw) do |event|
  event.respond 'Raw response: ' + format('%.1800s', ru_info.raw_data.to_s)
end

newsgirl.command(:info) do |event|
  event.channel.send_embed('', mes)
  event.respond 'Response length: ' + ru_info.data.to_s.length.to_s
end

newsgirl.command(:update) do |event|
  event.respond 'loading...'
  event.respond JSON.pretty_generate(ru_info.update)
  event.respond 'Response length: ' + ru_info.data.to_s.length.to_s
end

newsgirl.run
