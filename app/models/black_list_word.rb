class BlackListWord < ActiveRecord::Base
  
  belongs_to :what
  
  validates :what_id,
            :presence => true,
            :uniqueness => true,
            :numericality => true

  validates :kind,
            :presence => true  
end
