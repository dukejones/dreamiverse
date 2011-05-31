class Book < ActiveRecord::Base
  belongs_to :user
  belongs_to :image
  has_many :entries
  
  #todo: copied from entry - refactor
  Level = {
    private:              0,
    anonymous:           50,
    users:              100,
    followers:          150,
    friends:            200,
    friends_of_friends: 300,
    everyone:           500
  }
  
end
