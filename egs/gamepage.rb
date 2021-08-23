%w[
  open-uri
  nokogiri
].each { |gem| require gem }

# ...
class GamePage
  attr_reader :description

  def initialize(url)
    @description = description_parse(url)
  end

  def description_parse(url)
    page = URI.open(url)
    description = Nokogiri::HTML(page).xpath("//div[@class='css-pfxkyb']").text
    File.delete(page)
    return description
  end

end
