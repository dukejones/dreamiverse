class Tag < ActiveRecord::Base
  BlacklistWords = BlacklistWord.all.each_with_object( {} ) do |blacklist_word, hash|
    hash[blacklist_word.word] = true
  end

  default_scope order('position')
  
  belongs_to :entry
  
  belongs_to :noun, :polymorphic => true
  
  validates_uniqueness_of :entry_id, :scope => [:noun_id, :noun_type], 
    :message => "This entry already has this tag."

  validates_presence_of :entry_id
  validates_presence_of :noun_id

  # Scopes
  # Custom vs. Auto : custom (default) is user-entered, auto is auto-generated
  def self.custom
    where( kind: 'custom' )
  end
  def self.auto
    where( kind: 'auto' )
  end
  
  # Pass it the class name of the model that you want the nouns of.
  def self.of_type(type)
    where(noun_type: type.to_s)
  end
  # Joins to a specific type. Acts like of_type but does a join and eager load.
  def self.join_to(type)
    joins(:noun.type(type)).includes(:noun)
  end
  # Runs the join query and returns an array of nouns. 
  # entry.tags.nouns_of_type(Emotion)  will return all Emotion objects tagged.
  def self.nouns_of_type(type)
    join_to(type).map(&:noun)
  end

  # Convenience methods for the above scopes
  # TODO : Change the naming for these to something clearer?
  def self.emotion
    join_to(Emotion)
  end
  def self.what
    join_to(What)
  end

  def self.emotions
    nouns_of_type(Emotion)
  end
  def self.whats
    nouns_of_type(What)
  end

  # Must join_to a noun_type before calling this method.
  def self.named(name)
    where(:noun => {:name => name})
  end

  # Scopes for Dictionaries; eager loading & joining
  # def self.eager_load_dictionary_words
  #   joins(:noun.type(What) => :dictionary_words.outer).includes(:noun => :dictionary_words)
  # end
  # def self.with_dictionary_words
  #   joins(:noun.type(What) => :dictionary_words).includes(:noun)
  # end
  
  # tag the entry with the top x auto tags, inserted after the custom tags
  def self.auto_generate_tags(entry, cloud_size = 16)
    entry.tags.auto.delete_all
    
    # titles get entered twice for double score
    tag_text = "#{entry.title} #{entry.title} #{entry.body}"
    
    # remove all html tags accidentally pasted in
    tag_text.gsub! %r{</?\w+((\s+\w+(\s*=\s*(?:".*?"|'.*?'|[^'">\s]+))?)+\s*|\s*)/?>}, ''
    # remove references to url's of any sort
    tag_text.gsub! %r{(https?://|www\.)([-\w\.]+)+(:\d+)?(/([\w/_\.]*(\?\S+)?)?)?}, ''
    # make spaces for ., --, and / for dream-typing -- e.g. done...but i ; kitchen--but no fridge ; airport/spaceport
    tag_text.gsub!(/\.+|\-\-+|\/|,/, ' ')
    # also get rid of possessives -- ruby's => ruby
    tag_text.gsub!(/'s/, '')
    
    auto_tag_words = tag_text.split(/\s+/)
    
    auto_scores = self.order_and_score_auto_tags(auto_tag_words)

    # which position to start with?
    custom_tag_count = entry.tags.of_type(What).custom.count
    position = custom_tag_count # initial position: after the custom tags
    auto_scores.first(cloud_size-custom_tag_count).each do |what, score|
      Tag.create(entry: entry, noun: what, position: position, kind: 'auto')
      position += 1
    end
  end

  # create hash  name => frequency with no blacklisted words.   
  def self.order_and_score_auto_tags(tag_words)
    tag_scores = tag_words.map(&:downcase).each_with_object({}) do |tag_word, tag_scores|
      if acceptable_tag?(tag_word) && what = What.for(tag_word)
        tag_scores[what] ||= 0
        tag_scores[what] += 1
      end
    end

    tag_scores.sort_by { |tag_word, tag_score| tag_score }.reverse
  end

  def self.acceptable_tag?(tag_word)
    !BlacklistWords[tag_word] && 
    !tag_word.starts_with?('http://') && 
    !tag_word.starts_with?('www.')
  end
  
  # udpate custom tag positions with an ordered, comma-delim list
  def self.order_custom_tags(entry_id,position_list)
    
    return false if (entry_id.nil? || position_list.nil?)
    
    entry = Entry.find_by_id(entry_id)
    
    old_positions = {}
    entry.tags.map{|t| old_positions[t.noun_id] = t.position}
    new_positions = position_list.split(',')   
    
    new_positions.each_index do |new_pos|
      noun_id = new_positions[new_pos].to_i
      if old_positions[noun_id] != new_pos # is this tag position out of synch?
        t = Tag.where(:entry_id => entry_id, :noun_id => noun_id, :kind => 'custom').first
        next if t.nil?
        t.position = new_pos
        t.save
      end
    end
  
    return true
  end  

end
