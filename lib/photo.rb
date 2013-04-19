# Class for storing data about photos in MongoDB

class Photo
  include Mongo

  @@db = nil
  @@instagram_configured = false

  # attr_accessor :thumb_url, :link_url, :screen_name, :timestamp

  # store hash into photos collection
  def self.store(values)
    collection.insert(values)
  end

  # get all, sorted by timestamp
  def self.all 
    rows = collection.find().sort(:timestamp)
  end

  # run an update of all, or all since a given max_id, returning results
  def self.refresh
    (refresh_twitter + refresh_instagram).shuffle
  end

  def self.destroy_all
    collection.drop
  end

  private

    def self.refresh_twitter
      max_id = get_max_id('twitter')
      response = nil
      if max_id
        response = TwitterSearchPhotos.search('#' + ENV['SEARCH_TAG'], since_id: max_id)
      else
        response = TwitterSearchPhotos.search('#' + ENV['SEARCH_TAG'])
      end
      set_max_id('twitter', response.max_id)
      twitter_results = []
      response.results.each do |result|
        photo_data = {
          screen_name: result.screen_name, 
          thumb_url: "#{result.media_url}:thumb", 
          link_url: result.display_url,
          created_at: result.created_at.to_s
        }

        Photo.store(photo_data)
        twitter_results << photo_data
      end
      twitter_results
    end

    def self.refresh_instagram
      configure_instagram
      max_id = get_max_id('instagram')
      results = nil
      if max_id
        results = Instagram.tag_recent_media(ENV['SEARCH_TAG'], max_id: max_id)
      else
        results = Instagram.tag_recent_media(ENV['SEARCH_TAG'])
      end
      max_result = results.max_by { |x| x['id'].to_i }
      set_max_id('instagram', max_result['id'].to_i)
      instagram_results = []
      results.each do |result|
        photo_data = {
          screen_name: result['user']['username'], 
          thumb_url:   result['images']['thumbnail']['url'], 
          link_url:    result['link'],
          created_at:  Time.at(result['created_time'].to_i).to_datetime.to_s
        }
        Photo.store(photo_data)
        instagram_results << photo_data
      end
      instagram_results
    end

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

    # get/set last ID returned from Twitter or Instagram
    def self.get_max_id(service)
      key = "#{service}_max_id"
      max_id = settings.find_one({ name: key })
      if max_id
        max_id["value"]
      else
        nil
      end
    end

    def self.set_max_id(service, val)
      key = "#{service}_max_id"
      settings.update({ name: key }, { name: key, value: val.to_s }, { upsert: true })
    end

    def self.configure_instagram
      return if @@instagram_configured
      Instagram.configure do |config|
        config.client_id     = ENV['INSTAGRAM_CLIENT_ID']
        config.client_secret = ENV['INSTAGRAM_CLIENT_SECRET']
      end
      @@instagram_configured = true
    end

end
