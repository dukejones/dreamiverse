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
  has_many :whats,  :through => :tags, :source => :noun, :source_type => 'What', :uniq => true
  has_many :whos,   :through => :tags, :source => :noun, :source_type => 'Who', :uniq => true
  has_many :wheres, :through => :tags, :source => :noun, :source_type => 'Where', :uniq => true
  has_many :emotions, :through => :tags, :source => :noun, :source_type => 'Emotion', :uniq => true
  
  has_one :view_preference, :as => "viewable", :dependent => :destroy
  accepts_nested_attributes_for :view_preference, :update_only => true
  
  has_many :links, :as => :owner
  accepts_nested_attributes_for :links

  has_and_belongs_to_many :images, :uniq => true
  belongs_to :main_image, :class_name => "Image"

  validates_presence_of :user
  validates_presence_of :body
  validates_presence_of :dreamed_at
  
  after_initialize :init_dreamed_at
  before_save :set_sharing_level
  before_save :set_main_image
  before_create :create_view_preference
  before_update :delete_links
  after_save :process_all_tags 

  def self.everyone
    where(sharing_level: Entry::Sharing[:everyone])
  end
  def self.friends
    where(sharing_level: Entry::Sharing[:friends])
  end
  def self.private 
    where(sharing_level: Entry::Sharing[:private])
  end
  def self.followers 
    where(sharing_level: Entry::Sharing[:followers])
  end
  def self.anonymous
    where(sharing_level: Entry::Sharing[:anonymous])
  end
  
  def self.order_by_starlight
    select('entries.*').
    from( "( #{Starlight.current_for('Entry').to_sql} ) as maxstars " ).
    joins("JOIN starlights ON starlights.id=maxstars.maxid").
    joins("JOIN entries ON entries.id=starlights.entity_id").
    order('starlights.value DESC')
  end
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
  def self.accessible_by(user)
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


  def self.list(viewer, viewed, lens, filters)
    filters ||= {}
    entry_scope = Entry.order('created_at DESC')
    entry_scope = entry_scope.where(type: filters[:type]) if filters[:type] # Type: visions,  dreams,  experiences

    if (lens == :field) || viewer.nil?
      if viewer
        entries = entry_scope.where(user_id: viewed.id).select {|e| viewer.can_access?(e) }
      else
        entries = entry_scope.select{|e| e.everyone? } 
      end
    elsif lens == :stream
      page_size = filters[:page_size] || 30
      # only entries within 10 days
      # top page_size of each
      entry_scope = entry_scope.where(:updated_at > 10.days.ago).limit(page_size)
      entry_scope = entry_scope.offset(page_size * (filters[:page].to_i - 1)) if filters[:page]

      # based on friend filter: 
      user_list = 
        if filters[:friend] == "friends"
          viewer.friends
        else
          viewer.following
        end
      entries = entry_scope.where(:user_id => user_list.map(&:id))
      # each should be sorted according to date or starlight
    end

    entries.select!{|e| viewer.can_access?(e) } if viewer # this is very, very slow.
    entries
  end

  def nouns
    whos + wheres + whats
    # tags.all(:include => :noun).map(&:noun) - seems to be slower.
  end

  
  # Create / find a What for each tag word.
  # Remove the what tags that are on this entry but not in the tag words.
  # Add all the tag words to this entry.
  def set_whats(tag_words)
    return unless tag_words

    new_whats = tag_words.map {|word| What.for word }
    (self.whats - new_whats).each {|extraneous_what| self.whats.delete(extraneous_what) }
    new_whats.each { |what| @entry.add_what_tag(what) }

  end


  def add_what_tag(what, kind = 'custom')
    if self.whats.exists?(what)
      tag = self.tags.where(noun: what).first
      tag.update_attribute(:kind, 'custom') unless tag.kind == 'custom'
    else
      tags.create(noun: what, position: tags.count, kind: kind)     
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

  def self.random
    Entry.where(:sharing_level ^ 0).first(:order => 'rand()')
  end
  
protected

  def set_main_image
    self.main_image ||= self.images.first
  end

  def set_sharing_level
    self.sharing_level ||= self.user._?.default_sharing_level || self.class::Sharing[:friends]
  end

  def init_dreamed_at
    self.dreamed_at ||= Time.zone.now
  end
end
