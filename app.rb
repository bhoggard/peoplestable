require './lib/photo'

get '/' do 
  redirect '/index.html'
end

get '/twitter' do
  Photo.refresh
  # json (Photo.all.to_a * 20)
  json Photo.all.to_a
end

