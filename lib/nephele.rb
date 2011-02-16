class Nephele
  
=begin
  responsible for scoring, storing and generating single entry tag clouds, 
  multi-entry tag clouds and tag context clouds (clouds attached to tags)
  started feb/2011 - doktorj@dreamcatcher.net
=end

  # downcase & strip non alpha numeric chars at begin/end of tag
  def self.prep_tag(tag)
    return tag.downcase.gsub(/^\W+|\W+$/, '') 
  end

  def delete_scores(entry_id)
    Tag.delete_all(:entry_id => entry_id) if entry_id > 0  
  end


  # render html tag cloud with css font sizes/colors
  # def self.render_single_entry_tag_cloud(entry)
  # 
  #   # puts "test: running render_single_entry_tag_cloud( "+ entry_id.to_s + "," + user_id.to_s + ")" 
  #   tag_scores = {}
  #   # tags = Tag.where(:entry_id => entry_id,:user_id => [user_id,2]).limit(16)
  #   tag = entry.tags.limit(16)
  #   tags.map{ |tag| tag_scores[tag.noun_id] = tag.score }
  #   
  # 
  #   
  # 
  #   # some test tag_scores
  #   # tag_scores = { 544=>11, 538=>8, 517=>6, 524=>4, 548=>32, 592=>1 }
  #   # tag_scores = { 544=>11, 538=>10, 517=>10, 524=>9, 548=>9, 592=>9, 516=>8, 551=>7, 537=>7, 566=>7, 549=>6, 523=>6, 589=>6, 581=>6, 564=>5, 547=>5 }
  # 
  #   maxSize = 8 # max font size class
  #   minSize = 1 # min font size class
  #   
  #   # largest and smallest hash values
  #   maxQty = tag_scores.values.max
  #   minQty = tag_scores.values.min
  # 
  # 
  #   # find the range of values
  #   spread = maxQty - minQty
  #   spread = 1 if spread == 0 # we want to avoid divide by zero errors
  #  
  #   # set the class_size increment
  #   step = (maxSize.to_f - minSize.to_f)
  #   step = step / spread.to_f
  # 
  #   #puts 'maxSize: ' + maxSize.to_s + ' minSize: ' + minSize.to_s + ' maxQty: ' + maxQty.to_s + ' minQty: ' + minQty.to_s;
  #   #puts ' spread: ' + spread.to_s#  + ' step: ' + step.to_f
  # 
  #   tag_cloud = []
  # 
  # 
  # 
  #   tag_scores.each do |what_id,score|
  #     what = What.find(what_id)
  #     
  #     class_size = minSize + ((score - minQty) * step).to_i # the to_i leaves us with a whole #
  #     #puts 'what_id: ' + what_id.to_s + ' name: ' + what.name +  ' score: ' + score.to_s + ' class_size: ' + class_size.to_s  
  #     tag_cloud.push('<div class="TC s-' + class_size.to_s + ' water">' + what.name.to_s + '</div>')
  #   end
  # 
  #   tag_cloud = tag_cloud.shuffle
  # 
  #   #puts 'tag_cloud: ' + tag_cloud.to_s
  #   
  # 
  #   # turn it into a string for the view
  #   tag_cloud_string = '' # init
  #   tag_cloud.each do |tag|
  #    tag_cloud_string = tag_cloud_string + tag
  #   end
  #   
  #   return tag_cloud_string
  # end

  def auto_generate_single_entry_tags(dream)
    tag_string = dream.body << ' ' + dream.title #concat body/title
    tags = tag_string.split(/\s+/)
    return score_tags(dream,tags)
  end

  # invoke processes for scoring custom tags and 
  # generating / scoring auto generated tags
  def process_single_entry_tags(dream)
    tag_scores = auto_generate_single_entry_tags(dream)
    puts 'test: tag_scores' + tag_scores.to_s #testing
  end

private ###################  

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