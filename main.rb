#!/usr/bin/env ruby

#  Create .env file with env vars:
#    TOKEN - unique bot token
#    ONIICHAN - bot admin id

#    PORT - port for webserver api
#    BIND - host variable, default '0.0.0.0'
#    MODE - production or debug environment

#    RAW_OUTPUT - file for write raw logs
#    FORMAT_OUTPUT - file for write format logs
#    SUBSCRIBERS_LIST - file for write subscribers ids

%w[
  json
  dotenv
  discordrb
].each { |gem| require gem }

Dotenv.load

%w[
  egs/debug
  egs/freegame
  egs/newspaper
  egs/timer
  egs/api
].each { |gem| require_relative gem }

subs_file_name = ENV['SUBSCRIBERS_LIST'].to_s

if File.exist? subs_file_name
  subscribers_file = File.open(subs_file_name, 'r')
  subscribers_list = subscribers_file.read.split(/\n/)
  subscribers_file.close
else
  File.new(subs_file_name, 'w').close
  subscribers_list = []
end

url = 'https://store-site-backend-static-ipv4.ak.epicgames.com/freeGamesPromotions'
url_ru_param = '?locale=ru&country=RU&allowCountries=RU'

raw_output_file = ENV['RAW_OUTPUT']
format_output_file = ENV['FORMAT_OUTPUT']

informations = FreeGamesData.new(url + url_ru_param)
newspapers_bundle = NewsPaperBundle.new(informations)

newsgirl = Discordrb::Commands::CommandBot.new token: ENV['TOKEN'], prefix: '!'

newsgirl.command(
  :sayonara,
  help_available: false,
  description: 'Завершить работу бота'
) do |event|
  break unless event.user.id.to_s == ENV['ONIICHAN']

  newsgirl.send_message(event.channel.id, 'sayonara.')
  newsgirl.stop
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
  :promo,
  description: 'Список действующих и ближайших акций.'
) do |event|
  newspapers_bundle.bundle.each { |news| event.channel.send_embed('', news.newspaper) }
  return nil
end

newsgirl.command(
  :subscribe,
  description: 'Подписаться на новости.'
) do |event|
  if subscribers_list.include? event.channel.id.to_s
    event.respond 'Я помню что вы просили приносить сюда новости)'
    return nil
  end

  subscribers_list.append event.channel.id.to_s
  update_subs_file(subs_file_name, subscribers_list)

  event.respond 'Хорошо, теперь я буду приносить новости и сюда)'
  puts format('Канал %s подписался на рассылку.', event.channel.name)
  mysubs(newsgirl, event, subscribers_list)
  return nil
end

newsgirl.command(
  :unscribe,
  description: 'Отписаться от новостей.'
) do |event|
  unless subscribers_list.include? event.channel.id.to_s
    event.respond 'Вас и так нет в моем списке рассылки('
    return nil
  end

  if event.channel.id.to_s == subscribers_list.delete(event.channel.id.to_s)
    event.respond 'Ладно, теперь я не буду приносить вам новости('
    puts format('Канал %s отказался от рассылки.', event.channel.name)
    update_subs_file(subs_file_name, subscribers_list)
  else
    puts 'Delete user error.'
  end
end

api = Api.new(informations)
timer = Timer.new(informations, newspapers_bundle, subscribers_list, newsgirl)

newsgirl.run

timer.thread.kill
api.thread.kill

puts "\nGoodbye."
exit 0
