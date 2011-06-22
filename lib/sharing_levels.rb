module SharingLevels

  Sharing = {
    private:              0,
    anonymous:           50,
    users:              100,
    followers:          150,
    friends:            200,
    friends_of_friends: 300,
    everyone:           500
  }

  def sharing
    self.class::Sharing.invert[sharing_level]
  end

  def everyone?
    (sharing_level == self.class::Sharing[:everyone])
  end
  
  def set_sharing_level
    self.sharing_level ||= self.user._?.default_sharing_level || self.class::Sharing[:friends]
  end
  
  module ClassMethods
    # Sharing scopes
    def everyone
      where(sharing_level: SharingLevels::Sharing[:everyone])
    end
    def friends
      where(sharing_level: SharingLevels::Sharing[:friends])
    end
    def private_sharing
      where(sharing_level: SharingLevels::Sharing[:private])
    end
    def followers 
      where(sharing_level: SharingLevels::Sharing[:followers])
    end
    def anonymous
      where(sharing_level: SharingLevels::Sharing[:anonymous])
    end
  end

  def self.included(base)
    base.class_eval do
    end

    base.extend(ClassMethods)
  end

end
