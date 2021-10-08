%w[
  http
  json
].each { |gem| require gem }

require_relative 'gamepage'

# ...
class FreeGamesData
  attr_reader :data,
              :raw_data,
              :response

  def initialize(url)
    @data = parse(request(url))
  end

  def update
    @data = parse(request(@response.uri))
  end

  def set(new_data)
    @data = new_data
  end

  private

  def request(url)
    return @response = HTTP.get(url)
  end

  def parse(response)
    return nil if response.code != 200

    processed_data = []
    @raw_data = JSON.parse(response)
    @raw_data['data']['Catalog']['searchStore']['elements'].each do |key, _obj|
      processed_data.push(serialization(key)) unless key['promotions'].nil?
    end
    return processed_data
  end

  def serialization(input)
    url = 'https://www.epicgames.com/store/ru/p/' +
          input['urlSlug'] + '?lang=ru'
    description = GamePage.new(url).description
    return {
      'url' => url,
      'title' => input['title'],
      'description' => description[0],
      'genre' => description[1],

      'logo' => lambda do
        input['keyImages'].each do |key, _obj|
          return key['url'] if key['type'] == 'OfferImageWide'
        end
      end.call,

      'price' => lambda do
        return {
          'originalPrice' => input['price']['totalPrice']['originalPrice'],
          'discountPrice' => input['price']['totalPrice']['discountPrice']
        }
      end.call,

      'promotions' => lambda do
        return {
          'promotionalOffers' =>
            unless input['promotions']['promotionalOffers'].empty?
              offers(input['promotions']['promotionalOffers'])
            end,
          'upcomingPromotionalOffers' =>
            unless input['promotions']['upcomingPromotionalOffers'].empty?
              offers(input['promotions']['upcomingPromotionalOffers'])
            end
        }
      end.call
    }
  end

  def offers(offer)
    return {
      'startDate' => offer[0]['promotionalOffers'][0]['startDate'],
      'endDate' => offer[0]['promotionalOffers'][0]['endDate']
    }
  end

end
