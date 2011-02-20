class Tag < ActiveRecord::Base
  belongs_to :entry
  belongs_to :noun, :polymorphic => true
  validates_uniqueness_of :entry_id, :scope => [:noun_id, :noun_type], 
    :message => "This entry already has this tag."
    
  attr_accessor :class_size

  def self.with_class_sizes_for(tags)
    min_score = tags.map(&:score).min
    max_score = tags.map(&:score).max
    tags = tags.shuffle
    tags.each do |tag|
      tag.class_size = quantize(tag.score, min_score, max_score)
    end
    tags
  end

  #  processes a raw list of tags, combines them with the custom tags and 
  # saves a sequenced list of tag scores to  the tags table for one entry
  def save_and_score_all_tags(entry,tags,total_scores = 16)
    # first let's process the auto-generated tags
    auto_scores = {}
    w = What.new    
    black_list_words = BlackListWord.find(:all).map{|i| i.word}
    
    # loop thru each tag, get a noun (what) id for each, then score frequencies
    tags.each do |tag|
      tag = w.prep(tag)
      blw = BlackListWord.find_by_word(tag)
      if blw.nil? # exclude black listed tags
        noun_id = nil #reset
        what = What.find_or_create_by_name(tag)
        noun_id = what.id
        if !noun_id.nil?      
          auto_scores[noun_id] += 1 if !auto_scores[noun_id].nil?
          auto_scores[noun_id] = 1 if auto_scores[noun_id].nil?                         
        end
      end
    end
        
    # sort results and keep the top (total_scores)
    auto_scores = auto_scores.sort_by { |key,value| value }.reverse   
    auto_scores = auto_scores.first(total_scores) # grab the top auto_scores 

    # now we want to look up the custom tags, and if there are < total_scores, then insert
    # the remaining auto generated tags / scores in their place 
    
    num_custom_tags = Tag.order('score asc').where(:entry_id => entry.id).limit(total_scores).count
    
    if (num_custom_tags < total_scores) # fill reset in with auto_tag_scores
      position = 0
      next_sequence = num_custom_tags += 1
      remaining_slots = (num_custom_tags > 0) ? total_scores - (num_custom_tags - 1) : total_scores
      
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

private
  # returns a number: 1-8
  def self.quantize(score, min_score, max_score)
    score = 8 if score > 8
    max_score = 8 if max_score > 8 
    score_range = (max_score == min_score) ? 1 : (max_score - min_score)
    scaling_factor = (8 - 1) / score_range
    (((score-min_score) * scaling_factor) + 1).to_i
  end
end
