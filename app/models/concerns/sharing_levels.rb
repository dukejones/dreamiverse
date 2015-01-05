module SharingLevels
  extend ActiveSupport::Concern

  Sharing = {
    private:              0,
    anonymous:           50,
    users:              100,
    followers:          150,
    friends:            200,
    friends_of_friends: 300,
    everyone:           500
  }

  included do
    # Sharing scopes
    def self.everyone
      where(sharing_level: SharingLevels::Sharing[:everyone])
    end
    def self.friends
      where(sharing_level: SharingLevels::Sharing[:friends])
    end
    def self.private_sharing
      where(sharing_level: SharingLevels::Sharing[:private])
    end
    def self.followers 
      where(sharing_level: SharingLevels::Sharing[:followers])
    end
    def self.anonymous
      where(sharing_level: SharingLevels::Sharing[:anonymous])
    end
  end

  def sharing
    self.class::Sharing.invert[sharing_level]
  end

  def everyone?
    (sharing_level == self.class::Sharing[:everyone])
  end
  
  def set_sharing_level
    self.sharing_level ||= self.user._?.default_sharing_level || self.class::Sharing[:friends]
  end

end
