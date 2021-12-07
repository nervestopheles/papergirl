%w[
  json
  sinatra
  thin
].each { |gem| require gem }

port = ENV['PORT'] || '8090'
bind = ENV['BIND'] || '0.0.0.0'
mode = ENV['MODE'] || 'debug'

set :port, port.to_i
set :bind, bind.to_s
if mode == 'production'
  set :environment, :production
else
  set :environment, :debug
end

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
