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
    newspaper = Discordrb::Webhooks::Embed.new(
      url: news['url'],
      title: news['title'],
      description: news['description'],
      image: Discordrb::Webhooks::EmbedImage.new(url: news['logo']),
      footer: Discordrb::Webhooks::EmbedFooter.new(text: 'Epic Games Store')
    )
    return newspaper
  end

end
