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
  
  has_and_belongs_to_many :images
  belongs_to :main_image, :class_name => "Image"
  
  validates_presence_of :user
  validates_presence_of :body
  
  before_save :set_sharing_level
  before_create :create_view_preference
  before_update :delete_links
  after_save :process_all_tags 


  scope :order_by_starlight, 
    select('entries.*').
    from( "( #{Starlight.current_for('Entry').to_sql} ) as maxstars " ).
    joins("JOIN starlights ON starlights.id=maxstars.maxid").
    joins("JOIN entries ON entries.id=starlights.entity_id").
    order('starlights.value DESC')
  
  scope :friends_with, -> user { 
    where( 
      user: { following: user, followers: user } 
    ).joins(:user => [:following, :followers])
  }
  
  scope :followed_by, -> user { 
    where( 
      user: { followers: user } 
    ).joins(:user => [:followers])
  }
  
  # where dream is public or i am friends with entry.user
  scope :accessible_by, -> user { 
    where( 
      (
        { sharing_level: Entry::Sharing[:everyone] } | 
        (
          { sharing_level: Entry::Sharing[:friends] } & 
          { user: { following: user, followers: user} }
        ) 
      )
    ).joins(:user.outer => [:following.outer, :followers.outer]).group(:id)
  }

  
  def nouns
    whos + wheres + whats
    # tags.all(:include => :noun).map(&:noun) - seems to be slower.
  end
  
  # def set_tags(types)
  #   
  #   types[:whats]._?.each do |word|
  #     add_what_tag( What.find_or_create_by_name(word) )
  #   end
  # end

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
  
  # save auto generated tags + score auto generated & users custom tags 
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

end
