class Legacy::Emotion < Legacy::Base
  set_table_name 'dreamEmotion'

  belongs_to 'dream', {foreign_key: "dreamId", class_name: "Legacy::Dream"}
  belongs_to 'option', {foreign_key: 'dreamEmotionOptionId', class_name: "Legacy::EmotionOption"}

  # setting?
end
