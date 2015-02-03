class Legacy::Dream < Legacy::Base
  set_table_name 'dream'
  
  def corresponding_object
    find_corresponding_entry
  end
  def find_corresponding_entry
    Entry.where(created_at: self.created_at, title: self.title).first
  end
  def find_or_create_corresponding_entry
    entry = find_corresponding_entry
    if entry.blank?
      entry = Migration::DreamImporter.new(self).migrate
      entry.save!
    end
    entry
  end

  has_many :comments, {foreign_key: 'dreamId', class_name: "Legacy::Comment"}
  has_many :emotions, {foreign_key: 'dreamId', class_name: "Legacy::Emotion"}
  has_many :dream_links, {foreign_key: 'dreamId', class_name: "Legacy::DreamLink"}
  has_many :views, {foreign_key: 'dreamId', class_name: "Legacy::DreamView"}

  has_many :dream_images, {foreign_key: 'dreamId', class_name: 'Legacy::DreamImage'}
  has_many :images, {through: :dream_images}
  belongs_to :default_image, {foreign_key: 'defaultImageId', class_name: 'Legacy::Image'}

  belongs_to :user, {foreign_key: 'userId', class_name: 'Legacy::User'}
  belongs_to :privacy_option, {foreign_key: 'privacyOptionId', class_name: 'Legacy::PrivacyOption'}
  belongs_to :category, {foreign_key: 'catId', class_name: 'Legacy::Category'}
  belongs_to :legacy_user, {foreign_key: 'userId', class_name: 'Legacy::User'}
  belongs_to :theme_setting, {foreign_key: 'themeSettingId', class_name: 'Legacy::ThemeSetting'}

  has_many :user_series, {foreign_key: 'dreamId', class_name: 'UserSeries'}
  
  def main_image_id
    default_image.find_corresponding_image._?.id unless default_image.nil?
  end
  
  def book_list
    user_series.map(&:option).map(&:title).join(',')
  end
  
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
    category.title
  end
  
  def user_id
    legacy_user.find_or_create_corresponding_user.id
  end
  
  def uniques
    self.views.count
  end
  
  def starlight
    self.views.count
  end
  
  def cumulative_starlight
    self.views.count
  end
  
  def whats
    tag_words = customTagsList.split(',').compact.map(&:strip).map(&:downcase).uniq
    whats = tag_words.map { |tag_word| What.for( tag_word ) }.compact

    debugger unless whats.all?{|w| w.valid? }
    whats
  end
end
