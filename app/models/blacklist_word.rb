class BlacklistWord < ActiveRecord::Base
    
  validates :word,
            :presence => true,
            :uniqueness => true

  validates :kind,
            :presence => true  
end
