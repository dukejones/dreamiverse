class Tag < ActiveRecord::Base
  belongs_to :entry
  acts_as_list :scope => :entry
  
  belongs_to :noun, :polymorphic => true
  validates_uniqueness_of :entry_id, :scope => [:noun_id, :noun_type], 
    :message => "This entry already has this tag."

  # tag the entry with the top x auto tags, inserted after the custom tags
  def self.auto_generate_tags(entry, cloud_size = 16)
    auto_tag_words = "#{entry.body} #{entry.title}".split(/\s+/)
    auto_scores = self.order_and_score_tag_words(auto_tag_words).first(cloud_size)

    # which position to start with?
    custom_tag_count = entry.tags.where(:kind => 'custom',:entry_id => entry.id).count

    (custom_tag_count...cloud_size).each do |position|
      auto_scores_index = position - custom_tag_count
      break if auto_scores_index >= auto_scores.size
      what, score = auto_scores[auto_scores_index]
      Tag.create(entry: entry, noun: what, position: position, kind: 'auto') 
    end
  end

  # create hash  name => # of times
  # no blacklisted words.
  # order the hash, keep top x, x = num auto tags we need    
  def self.order_and_score_tag_words(tag_words)
    tag_scores = tag_words.each_with_object({}) do |tag_word, tag_scores|
      if (BlackListWord.where(word: tag_word).count < 1)
        what = What.find_or_create_by_name(tag_word)
        if !what.id.nil? 
          tag_scores[what] ||= 0
          tag_scores[what] += 1
        end
      end
    end

    tag_scores.delete_if {|tag_word, tag_score| BlackListWord.where(word: tag_word).count > 0 }
    tag_scores.sort_by { |tag_word, tag_score| tag_score }.reverse
  end
end
