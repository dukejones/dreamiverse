class ProcessAllTags
  @queue = :tags_queue
  def self.perform(entry_id)
    entry = Entry.find(entry_id)
    Tag.auto_generate_tags(entry)
    entry.reorder_tags   
  end
end