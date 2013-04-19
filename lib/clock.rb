require 'bundler/setup'
Bundler.require(:default)

if settings.development?
  require 'dotenv'
  Dotenv.load
end
require './app'

Clockwork.every(1.minute, 'Photo refresh') { Photo.new(AppDB.db_connection).refresh }


