class Tag < ActiveRecord::Base
  belongs_to :entry
  
  belongs_to :noun, :polymorphic => true
  validates_uniqueness_of :entry_id, :scope => [:noun_id, :noun_type, :kind], 
    :message => "This entry already has this tag."

  # tag the entry with the top x auto tags, inserted after the custom tags
  def self.auto_generate_tags(entry,cloud_size = 16)   
    Tag.delete_all(:entry_id => entry.id,:kind => 'auto') 
        
    auto_tag_words = "#{entry.body} #{entry.title}".split(/\s+/)
    auto_scores = self.sort_and_score_auto_tags(auto_tag_words).first(cloud_size)
    
    # drJ tests
    # existing_custom_names = entry.custom_tags.map(&:name)
    # auto_scores.delete_if{|what,score| existing_custom_scores.include(what.name)}

    # which position to start with?
    custom_tag_count = entry.tags.where(:kind => 'custom',:entry_id => entry.id).count  
    
    (custom_tag_count...cloud_size).each do |position|
      auto_scores_index = position - custom_tag_count
      break if auto_scores_index >= auto_scores.size
      what, score = auto_scores[auto_scores_index]
      Tag.create(entry: entry, noun: what, position: position, kind: 'auto')     
    end
  end

  # create hash  name => frequency with no blacklisted words.   
  def self.sort_and_score_auto_tags(tag_words)   
    tag_scores = tag_words.each_with_object({}) do |tag_word, tag_scores|
      if (BlacklistWord.where(word: tag_word).count < 1)
        what = What.find_or_create_by_name(tag_word)
        if !what.id.nil? 
          tag_scores[what] ||= 0
          tag_scores[what] += 1
        end
      end
    end

    tag_scores.delete_if { |tag_word, tag_score| BlacklistWord.where(word: tag_word).count > 0 }
    tag_scores.sort_by { |tag_word, tag_score| tag_score }.reverse
  end

  # udpate custom tag positions with an ordered, comma-delim list
  def self.sort_custom_tags(entry_id,position_list)
    
    return false if (entry_id.nil?|position_list.nil?)
    
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
  
  def get_next_custom_position(entry_id)
    entry = Entry.find_by_id(entry_id)
    Tag.where(:entry_id => entry_id, :kind => 'custom').count.to_i
  end
  
end
