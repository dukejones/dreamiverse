module ActiveRecord
  class Base
    has_many :starlights, :as => :entity
    has_one  :starlight, :as => :entity, :order => "id DESC"
  end
end