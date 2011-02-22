class Legacy::EmotionOption < Legacy::Base
  set_table_name 'dreamEmotionOption'

  def name
    title
  end
  
end
