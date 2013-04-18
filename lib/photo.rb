# Class for storing data about photos in MongoDB

class Photo
  include Mongo

  @@db = nil

  # attr_accessor :thumb_url, :link_url, :screen_name, :timestamp

  # store hash into photos collection
  def self.store(values)
    collection.insert(values)
  end

  # get all, sorted by timestamp
  def self.all 
    rows = collection.find().sort(:timestamp)
  end

  # run an update of all, or all since a given max_id
  def self.refresh
    max_id = get_max_id
    response = nil
    if max_id
      response = TwitterSearchPhotos.search('#' + ENV['SEARCH_TAG'], since_id: max_id)
    else
      response = TwitterSearchPhotos.search('#' + ENV['SEARCH_TAG'])
    end
    set_max_id(response.max_id)
    response.results.each do |result|
      Photo.store(
        screen_name: result.screen_name, 
        thumb_url: "#{result.media_url}:thumb", 
        link_url: result.display_url,
        created_at: result.created_at.to_s
      )
    end
    true
  end

  def self.destroy_all
    collection.drop
  end

  private

    def self.db
      return @@db if @@db
      if ENV['MONGOHQ_URL']
        db = URI.parse(ENV['MONGOHQ_URL'])
        db_name = db.path.gsub(/^\//, '')
        @@db = Mongo::Connection.new(db.host, db.port).db(db_name)
        @@db.authenticate(db.user, db.password) unless (db.user.nil? || db.user.nil?)
        @@db
      else
        client = MongoClient.new
        @@db = client["peoplestable_development"]
      end
    end

    def self.collection
      db['photos']
    end

    def self.settings
      db['settings']
    end

    def self.get_max_id
      max_id = settings.find_one({ name: 'last_max_id' })
      if max_id
        max_id["value"]
      else
        nil
      end
    end

    def self.set_max_id(val)
      settings.update({ name: 'last_max_id' }, { name: 'last_max_id', value: val }, { upsert: true })
    end

end
