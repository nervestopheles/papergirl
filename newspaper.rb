%w[
  discordrb
].each { |gem| require gem }

# ...
class Newspaper
  attr_reader :newspaper

  def initialize(news)
    @newspaper = parse(news)
  end

  def parse(news)
    newspaper = Discordrb::Webhooks::Embed.new
    newspaper.url = news['url']
    newspaper.title = news['title']
    newspaper.description = news['description']
    newspaper.image = logo(news['logo'])
    return newspaper
  end

  def logo(url)
    obj = {}
    obj['url'] = url
    return obj
  end

end
