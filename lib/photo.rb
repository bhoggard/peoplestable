# Class for storing data about photos in MongoDB

class Photo
  include Mongo

  # attr_accessor :thumb_url, :link_url, :screen_name, :created_at

  # store hash into photos collection
  def self.store(db,values)
    collection(db).insert(values)
  end

  # get all, sorted by created_at
  def self.all(db) 
    collection(db).find().sort(:created_at)
  end

  # get all since created_at timestamp
  def self.all_since(db, timestamp)
    collection(db).find({ created_at: { :$gt => timestamp } }).sort(:created_at)
  end

  # run an update of all, or all since a given max_id, returning results
  def self.refresh(db)
    # only do this once every 60 seconds
    (refresh_twitter(db) + refresh_instagram(db)).shuffle
  end

  private

    def self.refresh_twitter(db)
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
          created_at: result.created_at.to_time.to_i.to_s
        }

        Photo.store(db, photo_data)
        twitter_results << photo_data
      end
      twitter_results
    end

    def self.refresh_instagram(db)
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
          created_at:  result['created_time']
        }
        Photo.store(db, photo_data)
        instagram_results << photo_data
      end
      instagram_results
    end

    def self.collection(db)
      db['photos']
    end

    def self.settings(db)
      db['settings']
    end

    # get/set last ID returned from Twitter or Instagram
    def self.get_max_id(db, service)
      key = "#{service}_max_id"
      max_id = settings(db).find_one({ name: key })
      if max_id
        max_id["value"]
      else
        nil
      end
    end

    def self.set_max_id(db, service, val)
      key = "#{service}_max_id"
      settings(db).update({ name: key }, { name: key, value: val.to_s }, { upsert: true })
    end

    def self.configure_instagram
      Instagram.configure do |config|
        config.client_id     = ENV['INSTAGRAM_CLIENT_ID']
        config.client_secret = ENV['INSTAGRAM_CLIENT_SECRET']
      end
    end

end
