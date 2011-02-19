module ActiveRecord
  class Base
    has_many :starlights, :as => :entity, :dependent => :destroy
    has_one  :starlight, :as => :entity, :order => "id DESC" do
      def change(amt)
        Starlight.change(proxy_target, amt)
      end
    end
  end
end