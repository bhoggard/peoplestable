require "sinatra"
require "sinatra/json"
require "multi_json"

if settings.development?
  require 'dotenv'
  Dotenv.load
end

require "twitter_search_photos"

# define a route that uses the helper
get '/twitter' do
  response = TwitterSearchPhotos.search(ENV['SEARCH_TAG'])
  results = []
  response.results.each do |result|
    results << { user: result.screen_name, thumb_url: "#{result.media_url}:thumb", display_url: result.display_url }
  end
  json max_id: response.max_id, results: results
end

