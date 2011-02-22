class Legacy::Dream < Legacy::Base
  set_table_name 'dream'
  
  has_many :comments, {foreign_key: 'dreamId', class_name: "Legacy::Comment"}
  has_many :emotions, {foreign_key: 'dreamId', class_name: "Legacy::Emotion"}

  has_many :dream_images, {foreign_key: 'dreamId', class_name: 'Legacy::DreamImage'}
  has_many :images, {through: :dream_images}

  belongs_to :privacy_option, {foreign_key: 'privacyOptionId', class_name: 'Legacy::PrivacyOption'}
  belongs_to :category, {foreign_key: 'catId', class_name: 'Legacy::Category'}
  belongs_to :user, {foreign_key: 'userId', class_name: 'Legacy::User'}
  belongs_to :theme_setting, {foreign_key: 'themeSettingId', class_name: 'Legacy::ThemeSetting'}

  
  def dreamed_at
    dreamDate
  end
  def created_at
    enteredDate
  end
  def updated_at
    lastModified
  end
  
  def body
    description
  end
  
  def sharing_level
    case privacy_option.title
    when 'public'
      Entry::Sharing[:everyone]
    when 'anonymous'
      Entry::Sharing[:anonymous]
    when 'private'
      Entry::Sharing[:private]
    end
  end
  
  def type
    category.title.capitalize
  end
  
  def user_id
    new_user = User.find_by_username_and_email user.username, user.email
    # raise "Must migrate users first!" if new_user.blank?
    if new_user.blank?
      new_user = Migration::UserImporter.new(user).migrate
      new_user.save!
    end
    
    new_user.id
  end
  
  def whats
    tag_words = customTagsList.split(',').compact.map(&:strip).map(&:downcase).uniq
    tag_words.map { |tag_word| What.find_or_create_by_name(tag_word) }
  end
end
