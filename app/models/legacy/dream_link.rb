class Legacy::DreamLink < Legacy::Base
  set_table_name 'dreamLink'
  
  has_one :dream, :foreign_key => 'dreamId', :class_name => 'Legacy::Dream'
  
  def url
    self.linkUrl
  end
  
  def title
    self.linkTitle
  end
  
  def owner_id
    dream = Legacy::Dream.find(self.dreamId)
    entry = dream.corresponding_object
    log("Can't find entry for dream: #{dream.id} #{dream.title[0..10]}") and return nil unless entry
    entry._?.id
  end
  
  def owner_type
    "Entry"
  end
  
end
  
