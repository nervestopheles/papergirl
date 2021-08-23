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
    doc = Nokogiri::HTML(URI.open(url))
    return doc.xpath("//div[@class='css-pfxkyb']").text
  end

end
