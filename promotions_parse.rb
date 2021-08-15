# TODO: Это работает, но какой ценой?

def promotions_parse(data, obj)
  startd = 'startDate'
  endd = 'endDate'

  data_promotions = data['promotions']
  obj_promotions = obj['promotions'] = {}

  current = 'promotionalOffers'
  obj_current = obj_promotions[current] = []
  unless data_promotions[current].nil?
    data_promotions[current].each do |external_key, _external_obj|
      external_key['promotionalOffers'].each do |internal_key, _internal_obj|
        internal_promotions = obj_current[-1] if obj_current.push({})
        internal_promotions[startd] = internal_key[startd]
        internal_promotions[endd] = internal_key[endd]
      end
    end
  end

  upcoming = 'upcomingPromotionalOffers'
  obj_upcoming = obj_promotions[upcoming] = []
  unless data_promotions[upcoming].nil?
    data_promotions[upcoming].each do |external_key, _external_obj|
      external_key['promotionalOffers'].each do |internal_key, _internal_obj|
        internal_promotions = obj_upcoming[-1] if obj_upcoming.push({})
        internal_promotions[startd] = internal_key[startd]
        internal_promotions[endd] = internal_key[endd]
      end
    end
  end

end
