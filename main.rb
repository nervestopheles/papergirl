#!/usr/bin/env ruby

%w[
  fgd
].each { |file| require_relative file }

url = 'https://store-site-backend-static-ipv4.ak.epicgames.com/freeGamesPromotions'
url_ru_param = '?locale=ru&country=RU&allowCountries=RU'

ru_info = FreeGamesData.new(url + url_ru_param)

# puts JSON.pretty_generate(ru_info.data)
# puts JSON.pretty_generate(ru_info.raw_data)

require 'discordrb'

bot = Discordrb::Bot.new token: 'ODc4MTk3MTYxMDA1ODA5NjY0.YR9q1w.ThtDadXA9UFKNAK6xear6xRw1jY'

mes = Discordrb::Webhooks::Embed.new
mes.title = 'Title!'

# У обычных серверов discord ограничение 2000 символов на сообщение.
# У серверов с nitro ограничение 4000 символов на сообщение.
bot.message(with_text: '!raw') do |event|
  event.respond 'Raw response: ' + format('%.1800s', ru_info.raw_data.to_s)
end

bot.message(with_text: '!info') do |event|
  event.channel.send_embed('qwerty', mes)
  event.respond 'Response length: ' + ru_info.data.to_s.length.to_s
end

bot.message(with_text: '!update') do |event|
  event.respond 'loading...'
  event.respond JSON.pretty_generate(ru_info.update)
  event.respond 'Response length: ' + ru_info.data.to_s.length.to_s
end

bot.run
