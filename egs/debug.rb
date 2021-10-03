# ...
def mysubs(newsgirl, event, list)
  my_subs = 'Мои подписчики:'
  list.each do |id|
    my_subs += "\n            - " \
    + newsgirl.channel(id).name.to_s
  end
  event.respond my_subs
  return nil
end
