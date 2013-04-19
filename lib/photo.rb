# Class for storing data about photos in MongoDB

class Photo
  include Mongo

  def initialize(db_connection)
    @db = db_connection
  end

  # attr_accessor :thumb_url, :link_url, :screen_name, :created_at

  # store hash into photos collection
  def store(values)
    collection.insert(values)
  end

  # get all, sorted by created_at
  def all
    collection.find().sort(:created_at)
  end

  # get all since created_at timestamp
  def all_since(timestamp)
    collection.find({ created_at: { :$gt => timestamp } }).sort(:created_at)
  end

  # run an update of all, or all since a given max_id, returning results
  def refresh
    # only do this once every 60 seconds
    timestamp = Time.now.to_i
    last_updated = get_last_updated
    if last_updated.nil? || (timestamp - last_updated.to_i) >= 60
      refresh_twitter
      refresh_instagram
      set_last_updated(timestamp)
    end
  end

  private

    def refresh_twitter
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

        store(photo_data)
        twitter_results << photo_data
      end
    end

    def refresh_instagram
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
        store(photo_data)
        instagram_results << photo_data
      end
    end

    def collection
      @db['photos']
    end

    def settings
      @db['settings']
    end

    # get/set last updated timestamp so we don't refresh too often
    def get_last_updated
      last = settings.find_one({ name: 'last_updated' })
      last ? last["value"] : nil
    end

    def set_last_updated(val)
      key = 'last_updated'
      settings.update({ name: key }, { name: key, value: val.to_s }, { upsert: true })
    end

    # get/set last ID returned from Twitter or Instagram
    def get_max_id(service)
      key = "#{service}_max_id"
      max_id = settings.find_one({ name: key })
      if max_id
        max_id["value"]
      else
        nil
      end
    end

    def set_max_id(service, val)
      key = "#{service}_max_id"
      settings.update({ name: key }, { name: key, value: val.to_s }, { upsert: true })
    end

    def configure_instagram
      Instagram.configure do |config|
        config.client_id     = ENV['INSTAGRAM_CLIENT_ID']
        config.client_secret = ENV['INSTAGRAM_CLIENT_SECRET']
      end
    end

end
