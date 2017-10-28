require 'sinatra'
require 'geoip'
require 'mongo'
require_relative 'lib/auth_helpers'

helpers AuthHelpers

Mongo::Logger.logger.level = Logger::WARN
class DatabaseNotFound < StandardError; end

configure do
  mongo = Mongo::Client.new(ENV['MONGOLAB_URI'])
  fail(DatabaseNotFound) if mongo.cluster.servers.empty?

  set :db, mongo
  set :geo, GeoIP.new('GeoLiteCity.dat')  
end

get '/csv' do
  protected!
  attachment 'email-sleuth.csv'
  docs = settings.db['users'].find
  headings = docs.to_a.map(&:keys).flatten.uniq.reject { |k| k == '_id' }
  rows = docs.to_a.map { |h| headings.map { |k| h[k] } }
  table = rows.unshift(headings)
  table.map { |r| r.join(',') }.join("\n")
end

get '/csv-openings' do
  protected!
  attachment 'email-sleuth-openings.csv'
  docs = settings.db['emails'].find
  headings = ['emailId', 'count']
  rows = docs.to_a.map { |r| [r['id'], r['users'].uniq.count] }
  table = rows.unshift(headings)
  table.map { |r| r.join(',') }.join("\n")
end

get '/clear' do
  protected!
  settings.db['users'].find.delete_many
  settings.db['emails'].find.delete_many
  'Cleared!'
end

get '/' do
  user_id = params['id']
  email_id = params['emailId']

  if !user_id || !email_id
   raise 'Bad Arguments'
  end

  user = { id: user_id, ip: request.ip }

  location = settings.geo.city(request.ip)
  if location
    user[:city] = location.city_name
    user[:country] = location.country_name
  end

  userDoc = settings.db['users'].find({ id: user_id })
  if userDoc.first
    userDoc.replace_one(user)
  else
    settings.db['users'].insert_one(user)
  end

  emailDoc = settings.db['emails'].find({ id: email_id })
  if emailDoc.first
    users = emailDoc.first['users'] << user_id
    emailDoc.replace_one({ id: email_id, users: users })
  else
    settings.db['emails'].insert_one({ id: email_id, users: [user_id] })
  end

  content_type 'image/gif'
  headers['Content-Disposition'] = 'inline;filename="tracking.gif"'
  Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==")
end

