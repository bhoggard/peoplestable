require './lib/app_db'
require './lib/photo'

configure do
  set :conn, AppDB.db_connection
end

configure :production do
  require 'newrelic_rpm'
end

get '/' do 
  redirect '/index.html'
end

get '/all_photos' do
  photo_client = Photo.new(settings.conn)
  photos = photo_client.all.to_a
  if photos.empty?
    photo_client.refresh
    photos = photo_client.all.to_a
  end
  json photos: photos, timestamp: photos.last["created_at"]
end

get '/photos_since/:timestamp' do
  photo_client = Photo.new(settings.conn)
  photo_client.refresh
  timestamp = params[:timestamp]
  photos = photo_client.all_since(timestamp).to_a
  # photos might be empty, then keep our existing timestamp
  unless photos.empty?
    timestamp = photos.last["created_at"] 
  end
  json photos: photos, timestamp: timestamp
end


