class Entry < ActiveRecord::Base
  self.inheritance_column = nil

  include SharingLevels
  
  include Starlit
  cascade_starlight_to :user
  
  attr_accessor :skip_auto_tags
  
  belongs_to :user
  belongs_to :book
  belongs_to :location, :class_name => "Where" 
  accepts_nested_attributes_for :location, :reject_if => :all_blank 

  has_many :entry_accesses
  has_many :authorized_users, :through => :entry_accesses, :source => :user
  has_many :comments
  has_one :latest_comment, :class_name => 'Comment', :order => 'created_at desc'

  # Tag associations
  has_many :tags, :dependent => :delete_all
  # has_many :custom_tags, 
  #          :through => :tags, 
  #          :source => :noun, 
  #          :source_type => 'What', 
  #          :conditions => ['kind = ?', 'custom'],
  #          :order => 'position asc',
  #          :limit => 16
  def what_tags
    self.tags.of_type(What)
  end
  has_many :whats,  :through => :tags, :source => :noun, :source_type => 'What', :order => 'position asc', :uniq => true
  has_many :whos,   :through => :tags, :source => :noun, :source_type => 'Who', :uniq => true
  has_many :wheres, :through => :tags, :source => :noun, :source_type => 'Where', :uniq => true
  has_many :emotions, :through => :tags, :source => :noun, :source_type => 'Emotion', :uniq => true
  
  has_one :view_preference, :as => "viewable", :dependent => :destroy
  accepts_nested_attributes_for :view_preference, :update_only => true
  
  has_many :links, :as => :owner

  has_and_belongs_to_many :images, :uniq => true
  belongs_to :main_image, :class_name => "Image"

  validates_presence_of :user
  #validates_presence_of :body
  validates_presence_of :dreamed_at
  
  after_initialize :init_dreamed_at
  before_save :set_sharing_level, :set_main_image, :replace_blank_titles
  before_create :create_view_preference
  # after_create :set_user_defaults
  after_save -> { @changed = (body_changed? || title_changed?) }
  after_commit :process_all_tags
  after_commit :pre_generate_images
  
  # Friends and Following scopes
  def self.friends_with(user)
    where( 
      user: { following: user, followers: user } 
    ).joins(:user => [:following, :followers])
  end
  
  def self.followed_by(user)
    where( 
      user: { followers: user } 
    ).joins(:user => [:followers])
  end
  
  # where dream is public or i am friends with entry.user
  # XXX: Does not work yet. Perfect the unit test.
  def self.accessible_by(user)
    where( 
      (
        { sharing_level: Entry::Sharing[:everyone] } | 
        { user: user } |
        (
          { sharing_level: Entry::Sharing[:friends] } & 
          { user: { following: user, followers: user} }
        )
      )
    ).joins(:user.outer => [:following.outer, :followers.outer]).group(:id)
  end

  def self.random
    self.everyone.where(:type ^ 'article').order("rand()").limit(1).first
  end

  def self.dreamstream(viewer, filters)
    filters ||= {}
    page_size = filters[:page_size] || 10
    page = filters[:page].to_i
    page = 1 if page <= 0
    
    # Universal scope
    entry_scope = Entry.order(:created_at.desc)
    entry_scope = entry_scope.where(type: filters[:type]) unless filters[:type].blank?
    entry_scope = entry_scope.where(:sharing_level ^ self::Sharing[:private]).where(:sharing_level ^ self::Sharing[:anonymous])

    # Others' Entries, paged.
    others_entries = entry_scope

    unless filters[:users].blank?
      user_ids_to_view =  # based on friend filter
        if filters[:users] == "friends"
          viewer.friends
        elsif filters[:users] == "following"
          viewer.following.select('users.id')
        end.map(&:id)
      user_ids_to_view.delete(viewer.id)
    
      others_entries = others_entries.where(:user_id => user_ids_to_view)
    else
      others_entries = others_entries.where(:user_id ^ viewer.id)
    end

    others_entries = others_entries.limit(page_size)
    others_entries = others_entries.offset(page_size * (page - 1))
    
    time_range = Entry.select('count(e.created_at) as num_entries, max(e.created_at) as max_time, min(e.created_at) as min_time').from("(#{others_entries.select(:created_at).to_sql}) as e").first
    return [] if time_range.num_entries == 0
    
    my_entries = entry_scope.where(:user => viewer)

    my_commented_entries = my_entries.joins(:comments).group('entries.id')

    comment_having = "max(comments.created_at) > '#{time_range.min_time.utc.to_s(:db)}'" if time_range.min_time
    comment_having << " AND max(comments.created_at) < '#{time_range.max_time.utc.to_s(:db)}'" if page != 1 && time_range.max_time
    my_commented_entries = my_commented_entries.having(comment_having) 

    my_uncommented_entries = my_entries.joins(:comments.outer).group('entries.id').having('count(comments.id)=0')
    my_uncommented_entries = my_uncommented_entries.where(:created_at.gt => time_range.min_time) if time_range.min_time
    my_uncommented_entries = my_uncommented_entries.where(:created_at.lt => time_range.max_time) if page != 1 && time_range.max_time

    entries = Entry.find_by_sql(%{
      (#{others_entries.select('entries.*, entries.created_at as stream_time').to_sql})
      UNION
      (#{my_uncommented_entries.select('entries.*, entries.created_at as stream_time').to_sql})
      UNION
      (#{my_commented_entries.select('entries.*, max(comments.created_at) as stream_time').to_sql})
      ORDER BY stream_time DESC
    })

    entries.select!{|e| viewer.can_access?(e) } if entries # this is very, very slow.
    entries
  end

  def self.dreamfield(viewer, viewed, filters={})
    entry_scope = Entry.order(:dreamed_at.desc)
    
    page_size = filters[:page_size] || 24
    page = filters[:page].to_i
    page = 1 if page <= 0
 
    entry_scope = entry_scope.where(type: filters[:type].singularize) unless filters[:type].blank?
    entry_scope = entry_scope.where(user_id: viewed.id)
    entry_scope = entry_scope.where(book_id: nil)
    entry_scope = entry_scope.limit(page_size) unless filters[:show_all] == "true"
    entry_scope = entry_scope.offset(page_size * (page - 1))
    
    if viewer
      entry_scope = entry_scope.where(:sharing_level ^ self::Sharing[:private])   unless viewer == viewed
      entry_scope = entry_scope.where(:sharing_level ^ self::Sharing[:anonymous]) unless viewer == viewed
      entry_scope = entry_scope.where(:sharing_level ^ self::Sharing[:followers]) unless viewer.following?(viewed) || viewer == viewed
      entry_scope = entry_scope.where(:sharing_level ^ self::Sharing[:friends])   unless viewer.friends_with?(viewed) || viewer == viewed
      # TODO: Put a log warning here if it eliminates any entries.  So we can get rid of this line eventually.
      entries = entry_scope.select {|e| viewer.can_access?(e) }
    else
      entries = entry_scope.where(sharing_level: self::Sharing[:everyone])
    end

    entries
  end
  
  def nouns
    whos + wheres + whats
    # tags.all(:include => :noun).map(&:noun) - seems to be slower.
  end

  def set_links(links_attrs)
    return unless links_attrs.kind_of? Array
    new_links = links_attrs.map do |attrs| 
      if link = self.links.where(url: attrs[:url]).first
        link.update_attribute(:title, attrs[:title]) unless attrs[:title] == link.title

      else
        link = Link.new(attrs)
      end
      link
    end
    self.links = new_links
  end

  def set_emotions(emotion_params)
    return if emotion_params.blank?
    emotion_params.each do |emotion_name, intensity|
      if emotion_tag = self.tags.emotion.named(emotion_name).first
        emotion_tag.update_attribute(:intensity, intensity)
      elsif intensity.to_i != 0
        self.tags.emotion.create(noun: Emotion.find_or_create_by_name(emotion_name), intensity: intensity)
      end
    end
  end
  
  # Create / find a What for each tag word.
  # Remove the what tags that are on this entry but not in the tag words.
  # Add all the tag words to this entry.
  def set_whats(tag_words)
    return unless tag_words
    new_whats = tag_words.map {|word| What.for word }.compact
    (self.tags.custom.whats - new_whats).each {|extraneous_what| self.whats.delete(extraneous_what) }
    new_whats.each { |what| self.add_what_tag(what) }
    
    reorder_tags
  end
  

  def add_what_tag(what, kind = 'custom')
    if self.whats.exists?(what)
      tag = self.tags.where(noun: what).first
      tag.update_attribute(:kind, 'custom') unless tag.kind == 'custom'
    else
      self.tags.create(noun: what, position: tags.count, kind: kind)     
    end
  end
  
  def add_where_tag(where, kind = 'custom')
    if self.wheres.exists?(where)
      tag = self.tags.where(noun: where).first
      tag.update_attribute(:kind, 'custom') unless tag.kind == 'custom'
    else
      tags.create(noun: where, position: tags.count, kind: kind)     
    end
  end

  def create_view_preference
    return if view_preference
    self.view_preference = user.view_preference.clone!
  end
  
  def reorder_tags
    # put all custom tags first
    self.what_tags.custom.each_with_index do |tag, index|
      tag.update_attribute :position, index
    end
    # then reorder auto tags
    first_auto_tag_position = self.what_tags.custom.count
    self.what_tags.auto.each_with_index do |tag, index|
      tag.update_attribute :position, first_auto_tag_position + index
    end
  end
  
  # save auto generated tags + score auto generated custom tags 
  def process_all_tags
    Rails.logger.warn('processing all tags...')
    return if @skip_auto_tags
    if @changed
      Tag.auto_generate_tags(self)
      reorder_tags
    end
  end
   
  def replace_blank_titles
    self.title = self.body.split(' ')[0..7].join(' ') if self.title.blank?
  end
  
protected

  def set_main_image
    unless self.images.include?(self.main_image)
      self.main_image = self.images.first
    end
  end

  # def set_user_defaults
  #   self.user._?.default_sharing_level = self.sharing_level
  #   self.user._?.default_entry_type = self.type
  #   self.user.save
  # end

  def init_dreamed_at
    self.dreamed_at ||= Time.zone.now
  end

  def pre_generate_images
    self.main_image._?.pre_generate(:facebook)
    # self.main_image._?.pre_generate(:stream_header)
    # self.main_image._?.pre_generate(:dreamfield_header)
  end
end
