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

  def serialization(data)
    obj = {}
    obj['title'] = data['title']
    obj['effectiveDate'] = data['effectiveDate']
    obj['promotions'] = promotions(data['promotions'])
    return obj
  end

  def offers(input, offer)
    start_date = 'startDate'
    end_date = 'endDate'
    output = []

    input[offer].each do |external_key, _external_obj|
      external_key['promotionalOffers'].each do |internal_key, _internal_obj|
        internal_promo = output[-1] if output.push({})
        internal_promo[start_date] = internal_key[start_date]
        internal_promo[end_date] = internal_key[end_date]
      end
    end
    return output
  end

  def promotions(input)
    now = 'promotionalOffers'
    upcoming = 'upcomingPromotionalOffers'

    output = {}
    output[now] = offers(input, now)
    output[upcoming] = offers(input, upcoming)
    return output
  end

end
