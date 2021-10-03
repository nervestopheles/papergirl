def update_subs_file(filepath, subscribers_list)
  subscribers_file = File.open(filepath, 'w')
  subscribers_file.write(subscribers_list.join("\n"))
  subscribers_file.close
end

def mysubs(newsgirl, event, list)
  my_subs = 'Мои подписчики:'
  list.each do |id|
    my_subs += "\n            - " \
    + newsgirl.channel(id).name.to_s
  end
  event.respond my_subs
  return nil
end
