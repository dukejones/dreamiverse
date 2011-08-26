class AutoGenerateTags
  @queue = :auto_generate_tags_queue
  
  # save auto generated tags + score auto generated & custom tags 
  def self.perform(entry_id)
    Rails.logger.warn('processing all tags as background task...')
    entry = Entry.find(entry_id)
    return if entry.nil?
    
    Tag.auto_generate_tags(entry)
    entry.reorder_tags   
    # log("running AutoGenerateTags process for id: #{entry_id}")
  end
end