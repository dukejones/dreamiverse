class Tag < ActiveRecord::Base
  belongs_to :entry
  belongs_to :noun, :polymorphic => true
  validates_uniqueness_of :entry_id, :scope => [:noun_id, :noun_type], 
    :message => "This entry already has this tag."
    
  attr_accessor :class_size

  def self.with_class_sizes_for(tags)
    min_score = tags.map(&:score).min
    max_score = tags.map(&:score).max
    tags.shuffle
    tags.each do |tag|
      tag.class_size = quantize(tag.score, min_score, max_score)
    end
    tags
  end

  # takes in a normal array of raw tags and returns hash of noun (what) ids
  # and their associated score/frequency - skip black listed words
  def score_auto_generated_tags(entry,tags,total_scores = 16)
    tag_scores = {}
    black_list_words = BlackListWord.find(:all).map{|w| w.what.name }
    w = What.new
    
    # loop thru each tag, get a noun (what) id for each, then score frequencies
    tags.each do |tag|
      tag = w.prep(tag)
      if !black_list_words.include?(tag) #exclude black listed tags        
        noun_id = nil #reset
        what = What.find_or_create_by_name(tag)
        noun_id = what.id
        if !noun_id.nil?      
          tag_scores[noun_id] += 1 if !tag_scores[noun_id].nil?
          tag_scores[noun_id] = 1 if tag_scores[noun_id].nil?                         
        end
      end
    end
    
    # sort results and keep the top (total_scores)
    tag_scores = tag_scores.sort_by { |key,value| value }.reverse #sort by value, reversed   
    tag_scores = tag_scores.first(total_scores) # grab the top total_scores elements
    tag_scores = Hash[*tag_scores.flatten] #convert array back into a hash
    
    # save the scores
    tag_scores.each do |noun_id,score|      
      Tag.create( :entry_id   => entry.id, 
                  :entry_type => entry.type,
                  :kind       => 'nephele',
                  :noun_id    => noun_id,
                  :noun_type  => 'What',
                  :score      => score)      
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
