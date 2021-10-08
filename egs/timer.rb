%w[
  http
  discordrb
].each { |gem| require gem }

%w[
  freegame
  newspaper
].each { |gem| require_relative gem }

# ...
class Timer
  attr_reader :thread

  def initialize(current_fgd, current_news_bundle, subs_list, newsgirl)
    @thread = Thread.new do
      loop do
        sleep(1 * 60 * 30) # 30 minut timer
        # sleep(1 * 10)
        response = HTTP.get(current_fgd.response.uri)
        if response.content_length == current_fgd.response.content_length
          puts 'No updates.'
          next
        end
        new_fgd = FreeGamesData.new(current_fgd.response.uri)
        if new_fgd.data.to_s == current_fgd.data.to_s
          puts 'Data miss.'
          next
        end
        current_fgd.set(new_fgd.data)
        subs_list.each do |id|
          current_news_bundle.bundle.each do |news|
            newsgirl.send_message(id, '', false, news.newspaper)
          end
        end
        puts 'Get updates.'
      end
    end
  end

end
