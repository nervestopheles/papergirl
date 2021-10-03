#!/usr/bin/env ruby

#  Create .env file with env vars:
#    TOKEN - unique bot token
#    ONIICHAN - bot admin id
#    RAW_OUTPUT - file for write raw logs
#    FORMAT_OUTPUT - file for write format logs
#    SUBSCRIBERS_LIST - file for write subscribers ids

%w[
  json
  dotenv
  discordrb
].each { |gem| require gem }

%w[
  egs/debug
  egs/freegame
  egs/newspaper
].each { |gem| require_relative gem }

Dotenv.load

url = 'https://store-site-backend-static-ipv4.ak.epicgames.com/freeGamesPromotions'
url_ru_param = '?locale=ru&country=RU&allowCountries=RU'

raw_output_file = ENV['RAW_OUTPUT']
format_output_file = ENV['FORMAT_OUTPUT']

informations = FreeGamesData.new(url + url_ru_param)
newsgirl = Discordrb::Commands::CommandBot.new token: ENV['TOKEN'], prefix: '!'

subscribers_file = File.open(ENV['SUBSCRIBERS_LIST'])
subscribers_list = []

newsgirl.command(
  :sayonara,
  help_available: false,
  description: 'Завершить работу бота'
) do |event|
  break unless event.user.id.to_s == ENV['ONIICHAN']

  newsgirl.send_message(event.channel.id, 'sayonara.')
  exit 0
end

# У обычных серверов discord ограничение 2000 символов на сообщение.
# У серверов с nitro ограничение 4000 символов на сообщение.
newsgirl.command(
  :log,
  help_available: false,
  description: 'Записать ответ сервера egs в лог.'
) do |event|
  break unless event.user.id.to_s == ENV['ONIICHAN']

  event.respond 'Raw response:'
  event.respond format('%.1200s', informations.raw_data.to_s) + '...'
  File.open(raw_output_file, 'w') do |file|
    file.write(JSON.pretty_generate(informations.raw_data))
  end
  File.open(format_output_file, 'w') do |file|
    file.write(JSON.pretty_generate(informations.data))
  end
  return nil
end

newsgirl.command(
  :update,
  description: 'Принудительно обновить информацию о бесплатных играх.'
) do |event|
  event.respond 'loading...'
  informations.update
  if informations.response.code == 200
    event.respond 'ok!'
  else
    event.respond 'server response code is not 200.'
  end
  return nil
end

newsgirl.command(
  :free,
  description: 'Список бесплатных игр на этой неделе.'
) do |event|
  event.respond 'Бесплатные игры на этой неделе:'
  informations.data.each do |info, _obj|
    next if info['price']['discountPrice'] != 0

    newspaper = Newspaper.new(info)
    event.channel.send_embed('', newspaper.newspaper)
  end
  return nil
end

newsgirl.command(
  :subscribe,
  description: 'Подписаться на новости.'
) do |event|
  subscribers_list.append event.channel.id.to_s
  event.respond 'Хорошо, теперь я буду приносить новости и сюда)'
  mysubs(newsgirl, event, subscribers_list)
  return nil
end

newsgirl.run
