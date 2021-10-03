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

  private

  def parse(news)
    var = Discordrb::Webhooks::Embed.new(
      url: news['url'],
      title: news['title'],
      description: news['description'],
      image: Discordrb::Webhooks::EmbedImage.new(url: news['logo']),
      footer: Discordrb::Webhooks::EmbedFooter.new(text: 'Epic Games Store'),
      color: 0x808080 # just gray color
    )
    var.add_field(
      name: 'Жанры:',
      value: news['genre']
    )
    var.add_field(
      name: 'Дата начала акции:', inline: true,
      value: date(DateTime.parse(news['promotions']['promotionalOffers']['startDate']))
    )
    var.add_field(
      name: 'Дата конца акции:', inline: true,
      value: date(DateTime.parse(news['promotions']['promotionalOffers']['endDate']))
    )
    return var
  end

  def date(date)
    return format('%s.%s.%s', date.day.to_s, date.month.to_s, date.year.to_s)
  end

end
