%w[
  json
  sinatra
  thin
].each { |gem| require gem }

set :port, 8090

# # дефолтный тип для всех контроллеров
before do
  content_type :json
end

get '/api/freegames' || '/api' || '/' do
  return $informations.data.to_json
end

get '/api/update' do
  $informations.update
  return 204
end

# ...
class Api
  attr_reader :thread

  def initialize(info)
    $informations = info
    @thread = Thread.new do
      Sinatra::Application.run!
    rescue StandardError => e
      $stderr << e.message
      $stderr << e.backtrace.join("\n")
    end
  end
end
