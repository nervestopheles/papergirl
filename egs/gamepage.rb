%w[
  open-uri
  nokogiri
].each { |gem| require gem }

# ...
class GamePage
  attr_reader :description

  private

  def initialize(url)
    @description = description_parse(url)
  end

  def description_parse(url)
    page = URI.open(url)
    html = Nokogiri::HTML(page)
    about_section = html.css('div[data-component=AboutSectionLayout]')
    about = about_section[0].text
    genre = about_section[1].text.split(/(Жанры)|(Особенности)/)[2].split(/(?=[А-Я])/).join(', ')
    description = about + "\n\nЖанры: " + genre
    File.delete(page)
    return description
  end

end
