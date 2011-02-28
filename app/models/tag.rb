class Tag < ActiveRecord::Base
  BlacklistWords = BlacklistWord.all.each_with_object( {} ) do |blacklist_word, hash|
    hash[blacklist_word.word] = true
  end

  belongs_to :entry
  
  belongs_to :noun, :polymorphic => true
  validates_uniqueness_of :entry_id, :scope => [:noun_id, :noun_type], 
    :message => "This entry already has this tag."

  validates_numericality_of :entry_id, :greater_than => 0
  validates_numericality_of :noun_id, :greater_than => 0

  scope :custom, where( kind: 'custom' )
  scope :auto,   where( kind: 'auto'   )

  # tag the entry with the top x auto tags, inserted after the custom tags
  def self.auto_generate_tags(entry,cloud_size = 16)   
    entry.tags.auto.delete_all
    
    # auto words from title/body - titles get entered twice for double score    
    auto_tag_words = "#{entry.title} #{entry.title} #{entry.body}".split(/\s+/)
    auto_scores = self.order_and_score_auto_tags(auto_tag_words)

    # which position to start with?
    custom_tag_count = entry.tags.custom.count
    position = custom_tag_count # initial position: after the custom tags
    auto_scores.first(cloud_size-custom_tag_count).each do |what, score|
      Tag.create(entry: entry, noun: what, position: position, kind: 'auto')
      position += 1
    end
  end

  # create hash  name => frequency with no blacklisted words.   
  def self.order_and_score_auto_tags(tag_words)   
    tag_scores = tag_words.each_with_object({}) do |tag_word, tag_scores|
      if (!BlacklistWords[tag_word])
        what = What.for(tag_word)
        tag_scores[what] ||= 0
        tag_scores[what] += 1
      end
    end

    tag_scores.sort_by { |tag_word, tag_score| tag_score }.reverse
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
