require './lib/photo'

get '/' do 
  redirect '/index.html'
end

get '/twitter' do
  json (Photo.all.to_a * 20)
end

