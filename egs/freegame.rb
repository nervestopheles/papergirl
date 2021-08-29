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
          input['productSlug'] + '?lang=ru'
    return {
      'url' => url,
      'title' => input['title'],
      'description' => GamePage.new(url).description,

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
          'promotionalOffers' => offers(input['promotions'], 'promotionalOffers'),
          'upcomingPromotionalOffers' => offers(input['promotions'], 'upcomingPromotionalOffers')
        }
      end.call
    }
  end

  def offers(input, offer)
    output = []
    input[offer].each do |key, _obj|
      key['promotionalOffers'].each do |promo, _obj|
        output.push(
          {
            'startDate' => promo['startDate'],
            'endDate' => promo['endDate']
          }
        )
      end
    end
    return output
  end

end
