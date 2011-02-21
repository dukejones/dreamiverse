class Tag < ActiveRecord::Base
  belongs_to :entry
  belongs_to :noun, :polymorphic => true
  validates_uniqueness_of :entry_id, :scope => [:noun_id, :noun_type], 
    :message => "This entry already has this tag."
    

  # create hash  name => # of times
  # no blacklisted words.
  # order the hash, keep top x, x = num auto tags we need
  def self.order_and_score_tag_words(tag_words)
    tag_scores = tag_words.each_with_object({}) do |tag_word, tag_scores|
      tag_scores[tag_word] ||= 0
      tag_scores[tag_word] += 1
    end
    
    tag_scores.delete_if {|tag_word, tag_score| BlackListWord.where(word: tag_word).count > 0 }
    
    tag_scores.sort_by { |tag_word, tag_score| tag_score }.reverse
  end

  # tag the entry with the top x auto tags, inserted after the custom tags
  def self.auto_generate_tags(entry, cloud_size = 16)
    tag_words = "#{entry.body} #{entry.title}".split(/\s+/)

    tag_scores = self.order_and_score_tag_words(tag_words).first(cloud_size)
    
    # how many?
    # which position to start with?
    custom_tag_count = entry.tags.where(:kind ^ 'auto').count

    (custom_tag_count...cloud_size).each do |position|
      tag_scores_index = position - custom_tag_count
      break if tag_scores_index >= tag_scores.size
      tag_word, score = tag_scores[tag_scores_index]
      what = What.find_or_create_by_name(tag_word)
      Tag.create(entry: entry, noun: what, position: position, kind: 'auto')
    end
    
  end

  
  #  processes a raw list of tags, combines them with the custom tags and 
  # saves a sequenced list of tag scores to  the tags table for one entry
  def save_and_score_all_tags(entry, tags, tag_cloud_size = 16)
    # first let's process the auto-generated tags
    auto_scores = {}
    
    # loop thru each tag, get a noun (what) id for each, then score frequencies
    tags.each do |tag_word|
      tag_word = What.clean(tag_word)
      if BlackListWord.where(word: tag_word).count == 0 # exclude black listed tags
        noun_id = nil #reset
        what = What.find_or_create_by_name(tag_word)
        noun_id = what.id
        if noun_id
          auto_scores[noun_id] ||= 0
          auto_scores[noun_id] += 1
        end
      end
    end

    # sort results and keep the top (tag_cloud_size)
    auto_scores = auto_scores.sort_by { |key,value| value }.reverse   
    auto_scores = auto_scores.first(tag_cloud_size) # grab the top auto_scores 

    # now we want to look up the custom tags, and if there are < tag_cloud_size, then insert
    # the remaining auto generated tags / scores in their place 
    
    if (entry.tags.count < tag_cloud_size) # fill reset in with auto_tag_scores
      position = 0
      next_sequence = num_custom_tags += 1
      remaining_slots = (num_custom_tags > 0) ? tag_cloud_size - (num_custom_tags - 1) : tag_cloud_size
      
      while (remaining_slots > 0)
        break if auto_tag_scores[position].nil? # we ran out of auto tags
        Tag.create( :entry_id   => entry.id, 
                    :entry_type => entry.type,
                    :kind       => 'auto',
                    :noun_id    => auto_scores[position][0],
                    :noun_type  => 'What',
                    :score      => next_sequence)      
        remaining_slots -= 1
        next_sequence += 1
        position += 1
      end
    end
  end
end
