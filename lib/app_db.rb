module AppDB
  include Mongo

  def self.db_connection
    if ENV['MONGOHQ_URL']
      db_uri = URI.parse(ENV['MONGOHQ_URL'])
      db_name = db_uri.path.gsub(/^\//, '')
      db = Mongo::Connection.new(db_uri.host, db_uri.port).db(db_name)
      db.authenticate(db_uri.user, db_uri.password) unless (db_uri.user.nil? || db_uri.user.nil?)
      db
    else
      client = MongoClient.new
      client["peoplestable_development"]
    end
  end
end
