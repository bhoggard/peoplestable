get '/' do 
  redirect '/index.html'
end

# define a route that uses the helper
get '/twitter' do
  response = TwitterSearchPhotos.search('#' + ENV['SEARCH_TAG'])
  results = []
  response.results.each do |result|
    results << { user: result.screen_name, thumb_url: "#{result.media_url}:thumb", display_url: result.display_url }
  end
  json max_id: response.max_id, results: results
end

