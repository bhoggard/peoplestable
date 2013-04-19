require './lib/photo'

get '/' do 
  redirect '/index.html'
end

get '/photos' do
  json Photo.refresh
end

get '/all_photos' do
  json Photo.all.to_a
end

