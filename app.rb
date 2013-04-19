require './lib/photo'

get '/' do 
  redirect '/index.html'
end

get '/all_photos' do
  photos = Photo.all.to_a
  latest = photos.max_by { |x| x["created_at"] }
  json photos: photos, timestamp: latest["created_at"]
end

get '/photos_since/:timestamp' do
  json Photo.all_since(params[:timestamp]).to_a
end


