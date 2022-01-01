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

  def initialize(fgd, nbund, slist, newsgirl)
    @thread = Thread.new do
      loop do
        sleep(60 * 15) # 15 minut timer
        # sleep(1 * 10)
        response = HTTP.get(fgd.response.uri)
        if response.content_length == fgd.response.content_length
          puts 'No updates.'
          next
        end
        new_fgd = FreeGamesData.new(fgd.response.uri)
        if new_fgd.data.to_s == fgd.data.to_s
          puts 'Data miss.'
          next
        end
        fgd.set(new_fgd.data)
        nbund = NewsPaperBundle.new(fgd)
        slist.each do |id|
          nbund.bundle.each do |news|
            newsgirl.send_message(id, '', false, news.newspaper) if news.price.zero?
          end
        end
        puts 'Get updates.'
      end
    end
  end

end
