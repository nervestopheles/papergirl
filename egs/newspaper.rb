%w[
  date
  discordrb
].each { |gem| require gem }

# ...
class Newspaper
  attr_reader :newspaper

  def initialize(news)
    @newspaper = parse(news)
  end

  def parse(news)
    var = Discordrb::Webhooks::Embed.new(
      url: news['url'],
      title: news['title'],
      description: news['description'],
      image: Discordrb::Webhooks::EmbedImage.new(url: news['logo']),
      color: 0xb0b0b0, # just gray color
      footer: Discordrb::Webhooks::EmbedFooter.new(text: 'Epic Games Store')
    )
    var.add_field(
      name: 'Дата начала акции:',
      value: lambda do
               ed = DateTime.parse(news['promotions']['promotionalOffers'][0]['startDate'])
               return format('%s.%s.%s', ed.day.to_s, ed.month.to_s, ed.year.to_s)
             end.call,
      inline: true
    )
    var.add_field(
      name: 'Дата конца акции:',
      value: lambda do
               poed = DateTime.parse(news['promotions']['promotionalOffers'][0]['endDate'])
               return format('%s.%s.%s', poed.day.to_s, poed.month.to_s, poed.year.to_s)
             end.call,
      inline: true
    )
    return var
  end

end
