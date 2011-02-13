class Nephele
  
=begin
  responsible for scoring, storing and generating single entry tag clouds, 
  multi-entry tag clouds and tag context clouds (clouds attached to tags)
  started feb/2011 - doktorj@dreamcatcher.net
=end


  # invoke processes for scoring custom tags and 
  # generating / scoring auto generated tags
  def process_single_entry_tags(dream)
    freqs = auto_generate_single_entry_tags(dream)
    puts 'test: freqs' + freqs.to_s #testing
  end

  # downcase & strip non alpha numeric chars at begin/end of tag
  def self.prep_tag(tag)
    return tag.downcase.gsub(/^\W+|\W+$/, '') 
  end

  # render html tag cloud with css font sizes/colors
  # this need ALOT of refactoring!!!
  def self.render_single_entry_tag_cloud(entry_id,user_id)
    rendered_fonts = []
    font_size = 16
    last_score = nil #init
    count = 0
    scores = Tag.where(:entry_id => entry_id,:user_id => user_id).limit(16)
    scores.map{ |s|     
      what = What.find_by_id(s.noun_id)     
      last_score = s.score if last_score.nil?
      puts 'noun_id: ' + s.noun_id.to_s + 'name: ' + what.name + ' score ' + s.score.to_s + 'font_size: ' + font_size.to_s + 'last_score: ' + last_score.to_s
      rendered_fonts.push('<font size="' + font_size.to_s + '">' + what.name + '</font>')
      font_size -= 1 if last_score != s.score
      last_score = s.score #if count > 0
    }
    rendered_fonts
  end



private ###################  
  
  def auto_generate_single_entry_tags(dream)
    tag_string = dream.body << ' ' + dream.title #concat body/title
    tags = tag_string.split(/\s+/)
    return score_freq(dream,tags)
  end
    
  # takes in a normal array of keywords and returns hash of noun (what) ids
  # and their associated score/freq
  def score_freq(dream,tags,num_scores = 16)
    freqs = {} #init hash
    black_list_words = BlackListWord.find(:all).map{|w| w.what.name }
    
    # loop thru each tag, get a noun (what) id for each, then score frequencies
    tags.each do |tag|
      tag = Nephele.prep_tag(tag)
      if !black_list_words.include?(tag) #exclude black listed tags        
        tag_id = nil #reset
        new_count = 0
        tag_id = get_what_id(tag) 
        if !tag_id.nil?          
          if freqs[tag_id].nil? 
            freqs[tag_id] = 1 # first instance of this tag_id
          else  
            freqs[tag_id]+=1  # increment score for this tag id
          end                 
        end
      end
    end
    
    # sort results and keep the top (num_scores)
    freqs = freqs.sort_by { |key,value| value }.reverse #sort by value, reversed   
    freqs = freqs.first(num_scores) # grab the top num_scores elements
    freqs = Hash[*freqs.flatten] #convert back into a hash
    
    # clear_scores(dream.id,nephele_id?) - for edit/update mode only
    # save the scores
    freqs.each do |tag_id,score|
      save_score(dream,nephele_id?,tag_id,'What',score)
    end  
              
    return freqs
  end

  # return the noun (what) id for a tag if it exists or insert it and returns 
  # the new or id or return nil if invalid tag
  def get_what_id(what)
    w = What.find_or_create_by_name(what)
    return w.id 
  end
  
  
  def nephele_id?
    u = User.find_by_username('nephele')
    return u.id 
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
  
  def clear_scores(entry_id,user_id)
    if entry_id > 0 && user_id > 0 
      Tag.delete_all(:entry_id => entry_id, :user_id => user_id)
    end  
  end  
  
end