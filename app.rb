require 'sinatra'
require 'geoip'
require_relative 'lib/simple_database'
require_relative 'lib/auth_helpers'
require_relative 'lib/bson_to_csv'

helpers AuthHelpers

configure do
  set :db, SimpleDatabase.new(ENV['MONGOLAB_URI'])
  set :geo, GeoIP.new('GeoLiteCity.dat')
end

get '/csv' do
  protected!
  attachment 'email-sleuth.csv'
  users = settings.db.get_all('users')
  BsonToCsv.parse(users)
end

get '/clear' do
  protected!
  settings.db.clear('users')
  'Cleared!'
end

get '/' do
  query = { id: params['id'] }
  user = params.merge(ip: request.ip)

  location = settings.geo.city(request.ip)
  if location
    user[:city] = location.city_name
    user[:country] = location.country_name
  end

  settings.db.create_or_replace('users', query, user)

  content_type 'image/gif'
  headers['Content-Disposition'] = 'inline;filename="tracking.gif"'
  Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==")
end
