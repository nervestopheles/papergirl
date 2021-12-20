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
      processed_data.push(serialization(key)) \
        if !key['promotions'].nil? \
           && !key['promotions'].empty? \
           && (!key['promotions']['promotionalOffers'].empty? || !key['promotions']['upcomingPromotionalOffers'].empty?)
    end
    return processed_data
  end

  def serialization(input)

    url = if input['productSlug'].nil?
            'https://www.epicgames.com/store/ru/p/' + input['urlSlug'] + '?lang=ru'
          else
            'https://www.epicgames.com/store/ru/p/' + input['productSlug'] + '?lang=ru'
          end

    description = if input['description'].nil? || (input['description'].length < 20)
                    GamePage.new(url).description
                  else
                    [].append(input['description'])
                  end

    return {
      'url' => url,
      'title' => input['title'],
      'description' => description[0],
      'genre' => description[1],

      'logo' => lambda do
        logo = nil
        input['keyImages'].each do |key, _obj|
          return key['url'] if key['type'] == 'OfferImageWide'

          logo = key['url'] if key['type'] == 'DieselStoreFrontWide'
          logo = key['url'] if logo.nil? && (key['type'] == 'VaultClosed')
        end
        return logo
      end.call,

      'price' => lambda do
        return {
          'originalPrice' => input['price']['totalPrice']['originalPrice'],
          'discountPrice' => input['price']['totalPrice']['discountPrice']
        }
      end.call,

      'promotions' => lambda do
        if input['promotions']['promotionalOffers'].empty?
          offers(input['promotions']['upcomingPromotionalOffers'])
        else
          offers(input['promotions']['promotionalOffers'])
        end
      end.call
    }
  end

  def offers(offer)
    if offer[0]['promotionalOffers'].nil?
      return {
        'startDate' => offer[0]['upcomingPromotionalOffers'][0]['startDate'],
        'endDate' => offer[0]['upcomingPromotionalOffers'][0]['endDate']
      }
    else
      return {
        'startDate' => offer[0]['promotionalOffers'][0]['startDate'],
        'endDate' => offer[0]['promotionalOffers'][0]['endDate']
      }
    end
  end

end
