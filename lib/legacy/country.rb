class Legacy::Country < Legacy::Base
  set_table_name 'country'
  def name
    title
  end
end
