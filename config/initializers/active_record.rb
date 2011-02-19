module ActiveRecord
  class Base
    has_many :starlights, :as => :entity, :dependent => :destroy
    # has_one  :starlight, :as => :entity, :order => "id DESC"
    def starlight
      Starlight.for(self)
    end

    # scope :order_by_starlight, joins(:starlights).group('starlights.id').having('max(starlights.id)').order('starlights.value DESC')
    
  end
end

