class BlackListWord < ActiveRecord::Base
  
  belongs_to :what
  
  validates :what_id,
            :presence => true,
            :uniqueness => true,
            :numericality => true

  validates :filter_type,
            :presence => true
  
end
