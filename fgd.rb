%w[
  http
  json
].each { |gem| require gem }

# ...
class FreeGamesData
  attr_reader :data,
              :raw_data,
              :response

  def initialize(url)
    @data = parse(request(url))
  end

  private

  def request(url)
    @response = HTTP.get(url)
    if @response.code != 200
      puts 'URL: ' + url
      puts 'Request respone is not 200 code.'
      return nil
    end
    return @response
  end

  def parse(response)
    return nil if response.nil?

    processed_data = []
    @raw_data = JSON.parse(response)
    @raw_data['data']['Catalog']['searchStore']['elements'].each do |key, _obj|
      processed_data.push(serialization(key)) unless key['promotions'].nil?
    end
    return processed_data
  end

  def serialization(input)
    output = {}
    output['title'] = input['title']
    output['effectiveDate'] = input['effectiveDate']
    output['logo'] = logo(input['keyImages'])
    output['price'] = price(input['price'])
    output['promotions'] = promotions(input['promotions'])
    return output
  end

  def logo(input)
    input.each do |key, _obj|
      return key['url'] if key['type'] == 'OfferImageWide'
    end
  end

  def price(input)
    output = {}
    output['originalPrice'] = input['totalPrice']['fmtPrice']['originalPrice']
    output['discountPrice'] = input['totalPrice']['fmtPrice']['discountPrice']
    return output
  end

  def promotions(input)
    output = {}
    output['promotionalOffers'] = offers(input, 'promotionalOffers')
    output['upcomingPromotionalOffers'] = offers(input, 'upcomingPromotionalOffers')
    return output
  end

  def offers(input, offer)
    output = []
    input[offer].each do |external_key, _external_obj|
      external_key['promotionalOffers'].each do |internal_key, _internal_obj|
        internal_promo = output[-1] if output.push({})
        internal_promo['startDate'] = internal_key['startDate']
        internal_promo['endDate'] = internal_key['endDate']
      end
    end
    return output
  end

end
