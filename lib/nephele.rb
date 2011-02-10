class Nephele
  
  # responsible for single entry tag clouds, multi-entry tag clouds
  # and tag context clouds & tag scoring/storage
  
  # invoke processes for scoring custom tags and 
  # generating / scoring auto generated tags
  def process_single_entry_tags(dream)
    freqs = auto_generate_single_entry_tags(dream)
    #BlackListWord.init.first_words
  end
  
  def auto_generate_single_entry_tags(dream)
    tags = dream.body.split(/\s+/) # make tags array by splitting body up
    freqs = score_freq(tags)
  end
  
  
  # return the noun (what) id for a tag if it exists or insert it and returns 
  # the new or id or return nil if invalid tag
  def get_what_id(what)
    #w = What.find_by_name(what)
    #w = What.create(name: what) if !w.id
    w = What.find_or_create_by_name(what)
    w.id 
  end  
  
  # takes in a normal array of keywords and returns hash of noun (what) ids
  # and their associated score/freq
  def score_freq(tags)
    freqs = {}
    # loop thru each tag, get a noun (what) id for each, then score frequencies
    tags.each do |tag|
      tag_id = nil #reset
      new_count = 0
      tag_id = get_what_id(tag) 
      
      if tag_id
        #new_count = 1 
        #new_count = freqs[tag_id] + 1
        if freqs.has_key?(tag_id)
          #new_count = freqs[tag_id] + 1  
          freqs[tag_id] = freqs[tag_id] + 1 # increment score for this tag id
        end
        #freqs[exists_id] = freqs[exists_id]++ if exists_id         
      end
    end
    return freqs
  end
  
  def self.prep_tag(tag)
    # downcase & strip non alpha numeric chars at begin/end of string
    return tag.downcase.gsub(/^\W+|\W+$/, '') 
  end  
    
end