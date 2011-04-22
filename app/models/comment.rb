class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry
  belongs_to :image
  has_many :links, :as => :owner

  def starlight_worthy?
    comments_by_this_user = self.entry.comments.where(:user_id => self.user_id).count
    (comments_by_this_user % 5) == 1 # only every 5 comments
  end
end
