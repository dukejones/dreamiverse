module ActiveRecord
  class Base
    has_many :starlights, :as => :entity, :dependent => :destroy
    # has_one  :starlight, :as => :entity, :order => "id DESC"
    def starlight
      Starlight.for(self)
    end
  end
end