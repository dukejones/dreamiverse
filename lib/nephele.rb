class Nephele
  
=begin
  responsible for scoring, storing and generating single entry tag clouds, 
  multi-entry tag clouds and tag context clouds (clouds attached to tags)
  started feb/2011 - doktorj@dreamcatcher.net
=end

  # get the id for username nephele - soon to replaced by the kind column
  def self.id?
    128
  end

  # Moved to Tag model
  # downcase & strip non alpha numeric chars at begin/end of tag
  #def self.prep_tag(tag)
  #  return tag.downcase.gsub(/^\W+|\W+$/, '') 
  #end

  ### Moved to Entry model
  #def delete_scores(entry_id)
  #  Tag.delete_all(:entry_id => entry_id) if !entry_id.nil?  
  #end

  ### Moved to Entry model
  #def auto_generate_single_entry_tags(dream)
  #  tag_string = dream.body << ' ' + dream.title #concat body/title
  #  tags = tag_string.split(/\s+/)
  #  return score_tags(dream,tags)
  #end

  ### Removed
  # invoke processes for scoring custom tags and 
  # generating / scoring auto generated tags
  #def process_single_entry_tags(dream)
  #  tag_scores = auto_generate_single_entry_tags(dream)
  #  puts 'test: tag_scores' + tag_scores.to_s #testing
  #end


  ### Move to Tag model? 
  # takes in a normal array of raw tags and returns hash of noun (what) ids
  # and their associated score/frequency - skip black listed words
  def self.score_auto_generated_tags(entry,tags,total_scores = 16)
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
    tag_scores.each do |tag_id,score|
      Nephele.save_auto_generated_score(entry,Nephele.id?,tag_id,'What',score)
    end  
  end

  # Moved to What model
  # return the noun (what) id for a tag if it exists or insert it and returns 
  # the new or id or return nil if invalid 
  #def get_what_id(what)
  #  w = What.find_or_create_by_name(what)
  #  return w.id 
  #end
  
  
  # insert a tags record
  def self.save_auto_generated_score(entry,user_id,noun_id,noun_type,score)
  
    Tag.create( :entry_id   => entry.id, 
                :entry_type => entry.type,
                :kind       => 'nephele',
                :noun_id    => noun_id,
                :noun_type  => noun_type,
                :score      => score)
  end   
end