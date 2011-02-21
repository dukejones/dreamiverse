class EntryAccess < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry
  
  Level = {
    block: 0,
    read: 20,
    write: 30,
    own: 50
  }
end