class Entry < ActiveRecord::Base
  self.inheritance_column = nil

  Sharing = {
    private:              0,
    anonymous:           50,
    users:              100,
    followers:          150,
    friends:            200,
    friends_of_friends: 300,
    everyone:           500
  }

  
  belongs_to :user
  belongs_to :location, :class_name => "Where" 
  accepts_nested_attributes_for :location, :reject_if => :all_blank 

  has_many :entry_accesses
  has_many :authorized_users, :through => :entry_accesses, :source => :user
  has_many :comments

  has_many :tags
  has_many :custom_tags, 
           :through => :tags, 
           :source => :noun, 
           :source_type => 'What', 
           :conditions => ['kind = ?', 'custom'],
           :order => 'position asc',
           :limit => 16
  has_many :custom_whats, :through => :custom_tags
  has_many :whats,  :through => :tags, :source => :noun, :source_type => 'What'
  has_many :whos,   :through => :tags, :source => :noun, :source_type => 'Who'
  has_many :wheres, :through => :tags, :source => :noun, :source_type => 'Where'
  has_many :emotions, :through => :tags, :source => :noun, :source_type => 'Emotion'
  
  has_one :view_preference, :as => "viewable", :dependent => :destroy
  accepts_nested_attributes_for :view_preference, :update_only => true
  
  has_many :links, :as => :owner
  accepts_nested_attributes_for :links
  def youtube_links
    []
  end
  
  has_and_belongs_to_many :images
  belongs_to :main_image, :class_name => "Image"

  validates_presence_of :user
  validates_presence_of :body
  
  before_save :set_sharing_level
  before_save :set_main_image
  before_create :create_view_preference
  before_update :delete_links
  after_save :process_all_tags 




  def everyone
    where(sharing_level: Entry::Sharing[:everyone])
  end
  def friends
    where(sharing_level: Entry::Sharing[:friends])
  end
  def private 
    where(sharing_level: Entry::Sharing[:private])
  end
  def followers 
    where(sharing_level: Entry::Sharing[:followers])
  end
  def anonymous
    where(sharing_level: Entry::Sharing[:anonymous])
  end
  
  def order_by_starlight
    select('entries.*').
    from( "( #{Starlight.current_for('Entry').to_sql} ) as maxstars " ).
    joins("JOIN starlights ON starlights.id=maxstars.maxid").
    joins("JOIN entries ON entries.id=starlights.entity_id").
    order('starlights.value DESC')
  end
  def friends_with(user)
    where( 
      user: { following: user, followers: user } 
    ).joins(:user => [:following, :followers])
  end
  
  def followed_by(user)
    where( 
      user: { followers: user } 
    ).joins(:user => [:followers])
  end
  
  # where dream is public or i am friends with entry.user
  def accessible_by(user)
    where( 
      (
        { sharing_level: Entry::Sharing[:everyone] } | 
        (
          { sharing_level: Entry::Sharing[:friends] } & 
          { user: { following: user, followers: user} }
        ) 
      )
    ).joins(:user.outer => [:following.outer, :followers.outer]).group(:id)
  end


  # This method smells bad.
  def self.list(viewer, viewed, lens, filters)
    filters ||= {}
    entry_scope = Entry.order('created_at DESC')
    entry_scope = entry_scope.where(type: filters[:type]) if filters[:type] # Type: visions,  dreams,  experiences
    
    if lens == :field
      # TODO: Make this a scope instead of looping over the array.
      if viewer
        entries = entry_scope.where(user_id: viewed.id).select {|e| viewer.can_access?(e) }
      else
        entries = entry_scope.select{|e| e.everyone? } 
      end
    elsif lens == :stream
      page_size = filters[:page_size] || 30
      # only entries within 10 days
      # top page_size of each
      entry_scope.where(:updated_at > 10.days.ago).limit(page_size)
      entry_scope = entry_scope.offset(page_size * (filters[:page].to_i - 1)) if filters[:page]

      entries = entry_scope.where(:user => viewer.following)
      # each should be sorted according to date & starlight
    end

    # debugger if entries.any?{|e| !viewer.can_access?(e) } # !!!! Comment this before release
    entries
  end

  # def stream_list_scoped
  #   entries = Entry.accessible_by(viewer)
  # 
  #   entries = entries.order('created_at DESC')
  #   
  #   # starlight: low, medium, high, off - for now just high
  #   entries = entries.order_by_starlight if filters[:starlight] == 'high'
  # 
  #   # friends, or following
  #   if filters[:friend] == 'friends'
  #     entries = entries.friends_with(viewer)
  #   elsif filters[:friend] == 'following'
  #     entries = entries.followed_by(current_user)
  #   end
  # 
  #   page_size = filters[:page_size] || 30
  #   entries = entries.limit(page_size)
  #   entries = entries.offset(page_size * (filters[:page].to_i - 1)) if filters[:page]
  #   
  # end
  
  def nouns
    whos + wheres + whats
    # tags.all(:include => :noun).map(&:noun) - seems to be slower.
  end

  
  def set_tags(types)
    new_whats = types[:whats].map {|word| What.for(word) }
    # whats to delete - those in whats but not in new_whats
    (whats - new_whats).each {|what| whats.delete(what) }

    new_whats.each do |what|
      add_what_tag( what )
    end
  end


  def add_what_tag(what, kind = 'custom')
    # if new custom tag is added
    # insert in front of all auto tags
    if whats.exists?(what)
      tag = tags.where(noun: what).first
      tag.update_attribute(:kind, 'custom') unless tag.kind == 'custom'
    else
      tags.create(noun: what, position: tags.count, kind: kind)     
    end
  end
 
  def sharing
    self.class::Sharing.invert[sharing_level]
  end
  def everyone?
    (sharing_level == self.class::Sharing[:everyone])
  end

  def create_view_preference
    return if view_preference
    self.view_preference = user.view_preference.clone!
  end
  
  def everyone?
    sharing_level == self.class::Sharing[:everyone]
  end

  def delete_links
    Link.delete_all(:owner_id => self.id)
  end

  def reorder_tags
    max_tags = 16
    # put all custom tags first
    tags.custom.each_with_index do |tag, index|
      tag.update_attribute :position, index
    end
    # then reorder auto tags - up to 16 total tags
    first_auto_tag_position = tags.custom.count
    tags.auto.each_with_index do |tag, index|
      if first_auto_tag_position + index < max_tags
        tag.update_attribute :position, first_auto_tag_position + index
      else
        tag.destroy
      end
    end
  end
  
  # save auto generated tags + score auto generated custom tags 
  def process_all_tags
    if body_changed?
      Tag.auto_generate_tags(self)
    end
    reorder_tags
  end 

protected

  def set_sharing_level
    sharing_level ||= user.default_sharing_level || self.class::Sharing[:friends]
  end

  def set_main_image
    self.main_image = self.images.first unless self.main_image_id?
  end
end
