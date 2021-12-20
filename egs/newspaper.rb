%w[
  date
  discordrb
].each { |gem| require gem }

# ...
class Newspaper
  attr_reader :newspaper,
              :price

  def initialize(news)
    @newspaper = parse(news)
    @price = news['price']['discountPrice'].to_i
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
    unless news['genre'].nil?
      var.add_field(
        name: 'Жанры:',
        value: news['genre']
      )
    end
    var.add_field(
      name: 'Дата начала акции:', inline: true,
      value: date(DateTime.parse(news['promotions']['startDate']))
    )
    var.add_field(
      name: 'Дата конца акции:', inline: true,
      value: date(DateTime.parse(news['promotions']['endDate']))
    )
    var.url = nil if var.title == 'Mystery Game'
    return var
  end

  def date(date)
    return format('%<day>s.%<month>s.%<year>s',
                  day: date.day.to_s,
                  month: date.month.to_s,
                  year: date.year.to_s)
  end

end

# ...
class NewsPaperBundle
  attr_reader :bundle

  def initialize(informations)
    @bundle = []
    informations.data.each do |info, _obj|
      # next if info['price']['discountPrice'] != 0

      @bundle.append Newspaper.new(info)
    end
  end

end
