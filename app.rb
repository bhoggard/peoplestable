require './lib/photo'

get '/' do 
  redirect '/index.html'
end

get '/all_photos' do
  photos = Photo.all.to_a
  json photos: photos, timestamp: photos.last["created_at"]
end

get '/photos_since/:timestamp' do
  timestamp = params[:timestamp]
  photos = Photo.all_since(timestamp).to_a
  # photos might be empty, then keep our existing timestamp
  unless photos.empty?
    timestamp = photos.last["created_at"] 
  end
  json photos: photos, timestamp: timestamp
end


