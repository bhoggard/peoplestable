require 'bundler/setup'
Bundler.require(:default)

if settings.development?
  require 'dotenv'
  Dotenv.load
end

require './app'
run Sinatra::Application
