class Image < ActiveRecord::Base

  scope :by, lambda { |artist| where(['artist=?', artist]) }

  # TODO: currently exact match - substring would be better (esp. notes, tags, etc.)
  scope :search, lambda { |params|
    # TIDY: can I do this more elegantly? (without the intermediate variable 'results')
    results = where(['title=? OR artist=? OR album=? OR year=? OR category=? OR genre=? OR notes=? OR tags=?', 
            params[:q], params[:q], params[:q], params[:q], params[:q], params[:q], params[:q], params[:q]])
    results = results.where(artist: params[:artist]) if params[:artist]
    results = results.where(album: params[:album]) if params[:album]
    results = results.where(title: params[:title]) if params[:title]
    results = results.where(year: params[:year]) if params[:year]
    results = results.where(tags: params[:tags]) if params[:tags]
    results = results.where(genre: params[:genres].split(',')) if params[:genres]
    results
  }

  def self.albums
    select("distinct(album)").map(&:album)
  end

  def self.artists
    select("distinct(artist)").map(&:artist)
  end

end
