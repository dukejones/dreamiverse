class Legacy::Comment < Legacy::Base
  set_table_name 'dreamComment'

  belongs_to :dream, {foreign_key: "dreamId", class_name: "Legacy::Dream"}
  belongs_to :user, {foreign_key: 'userId', class_name: "Legacy::User"}
  
  def body
    comment
  end
  
  def user_id
    # user.find_or_create_corresponding_user.id
    new_user = user.find_corresponding_user
    raise("Could not find user: #{user.username} #{user.email}") unless new_user
    new_user.id
  end
  
  def entry_id
    # dream.find_or_create_corresponding_entry.id
    entry = dream.find_corresponding_entry
    raise("Could not find entry: '#{dream.title}'") unless entry
    entry.id
  end
  
  def image_id
    nil
  end
  
  def created_at
    commentDate
  end
  
  def updated_at
    commentDate
  end
end
