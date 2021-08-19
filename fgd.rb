# ...
class FreeGamesData
  def initialize(url)
    @data = parse(request(url))
  end

  def get
    if @data.nil?
      puts 'Error. Returns null.'
      return nil
    end
    return @data
  end

  def raw
    return @raw
  end

  def request(url)
    response = HTTP.get(url)
    if response.code != 200
      puts 'URL: ' + url
      puts 'Request respone is not 200 code.'
      return nil
    end
    return response
  end

  def parse(response)
    return nil if response.nil?

    obj = []
    @raw = JSON.parse(response)
    @raw['data']['Catalog']['searchStore']['elements'].each do |key, _obj|
      next if key['promotions'].nil?

      obj.push(serialization(key))
    end
    return obj
  end

  def serialization(data)
    obj = {}
    obj['title'] = data['title']
    obj['effectiveDate'] = data['effectiveDate']
    obj['promo'] = promotions(data)
    return obj
  end

  def promotions(input)
    startd = 'startDate', endd = 'endDate'

    input_promotions  = input['promotions']
    output_promotions = {}

    current = 'promotionalOffers'
    output_current_promo = output_promotions[current] = []
    input_promotions[current].each do |external_key, _external_obj|
      external_key['promotionalOffers'].each do |internal_key, _internal_obj|
        internal_promotions = output_current_promo[-1] if output_current_promo.push({})
        internal_promotions[startd] = internal_key[startd]
        internal_promotions[endd] = internal_key[endd]
      end
    end

    upcoming = 'upcomingPromotionalOffers'
    output_upcoming_promo = output_promotions[upcoming] = []
    input_promotions[upcoming].each do |external_key, _external_obj|
      external_key['promotionalOffers'].each do |internal_key, _internal_obj|
        internal_promotions = output_upcoming_promo[-1] if output_upcoming_promo.push({})
        internal_promotions[startd] = internal_key[startd]
        internal_promotions[endd] = internal_key[endd]
      end
    end
    return output_promotions
  end
end
