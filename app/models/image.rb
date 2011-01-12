class Image < ActiveRecord::Base

  scope :by, lambda { |artist| where(artist: artist) }

  # TIDY: where({}) causes unnecessary clone, possible performance hit?
  scope :sectioned, lambda { |section| where(section ? {section: section} : {}) }

  # TODO: currently exact match - substring would be better (esp. notes, tags, etc.)
  # TIDY: can I do this more elegantly? (without the intermediate variable 'results')
  scope :search, lambda { |params|
    # search term
    results = where(['title=? OR artist=? OR album=? OR year=? OR category=? OR genre=? OR notes=? OR tags=?', 
            params[:q], params[:q], params[:q], params[:q], params[:q], params[:q], params[:q], params[:q]])
    # filters
    results = results.where(artist: params[:artist]) if params[:artist]
    results = results.where(album: params[:album]) if params[:album]
    results = results.where(title: params[:title]) if params[:title]
    results = results.where(year: params[:year]) if params[:year]
    results = results.where(tags: params[:tags]) if params[:tags]
    # genres
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
