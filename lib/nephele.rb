class Nephele
  
=begin
  responsible for scoring, storing and generating single entry tag clouds, 
  multi-entry tag clouds and tag context clouds (clouds attached to tags)
  started feb/2011 - doktorj@dreamcatcher.net
=end

  # Move to Tag model?
  # downcase & strip non alpha numeric chars at begin/end of tag
  def self.prep_tag(tag)
    return tag.downcase.gsub(/^\W+|\W+$/, '') 
  end

  ### Move to Tag model?
  def delete_scores(entry_id)
    Tag.delete_all(:entry_id => entry_id) if entry_id > 0  
  end

  ### Move to Entry model?
  def auto_generate_single_entry_tags(dream)
    tag_string = dream.body << ' ' + dream.title #concat body/title
    tags = tag_string.split(/\s+/)
    return score_tags(dream,tags)
  end

  ### Move to Tag model?
  # invoke processes for scoring custom tags and 
  # generating / scoring auto generated tags
  def process_single_entry_tags(dream)
    tag_scores = auto_generate_single_entry_tags(dream)
    puts 'test: tag_scores' + tag_scores.to_s #testing
  end

private ###################  

  ### Move to Tag model? + rename to score_tag_frequencies
  # takes in a normal array of keywords and returns hash of noun (what) ids
  # and their associated score/freq
  def score_tags(dream,tags,num_scores = 16)
    tag_scores = {} #init hash
    black_list_words = BlackListWord.find(:all).map{|w| w.what.name }
    
    # loop thru each tag, get a noun (what) id for each, then score frequencies
    tags.each do |tag|
      tag = Nephele.prep_tag(tag)
      if !black_list_words.include?(tag) #exclude black listed tags        
        tag_id = nil #reset
        new_count = 0
        tag_id = get_what_id(tag) 
        if !tag_id.nil?          
          if tag_scores[tag_id].nil? 
            tag_scores[tag_id] = 1 # first instance of this tag_id
          else  
            tag_scores[tag_id]+=1  # increment score for this tag id
          end                 
        end
      end
    end
    
    # sort results and keep the top (num_scores)
    tag_scores = tag_scores.sort_by { |key,value| value }.reverse #sort by value, reversed   
    tag_scores = tag_scores.first(num_scores) # grab the top num_scores elements
    tag_scores = Hash[*tag_scores.flatten] #convert back into a hash
    
    # clear_scores(dream.id,nephele_id?) - for edit/update mode only
    # save the scores
    tag_scores.each do |tag_id,score|
      save_score(dream,nephele_id?,tag_id,'What',score)
    end  
              
    return tag_scores
  end

  # return the noun (what) id for a tag if it exists or insert it and returns 
  # the new or id or return nil if invalid tag
  def get_what_id(what)
    w = What.find_or_create_by_name(what)
    return w.id 
  end
  
  
  def nephele_id?
    128
    # u = User.find_by_username('nephele')
    # return u.id 
  end
  
  # insert a tags record
  def save_score(dream,user_id,noun_id,noun_type,score)
  
    Tag.create( :entry_id   => dream.id, 
                :entry_type => 'Dream',
                :user_id    => user_id,
                :noun_id    => noun_id,
                :noun_type  => 'What',
                :score      => score)
  end
    
end