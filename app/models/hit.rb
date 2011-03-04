class Hit < ActiveRecord::Base
  belongs_to :user
  
  scope :recent, -> { where(["updated_at > ?", 24.hours.ago]).order("updated_at DESC") }
  
  def self.unique? url_path, ip, user=nil
    previous_hit = self.recent.where(ip_address: ip, url_path: url_path).first
    if previous_hit
      previous_hit.update_attribute(:updated_at, Time.zone.now)
      false
    else
      Hit.create!({url_path: url_path, ip_address: ip, user: user})
      true
    end
  end
end
