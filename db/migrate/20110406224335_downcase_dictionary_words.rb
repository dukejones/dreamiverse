class DowncaseDictionaryWords < ActiveRecord::Migration
  def self.up
    Word.all.each do |word|
      word.update_attribute(:name, word.name.downcase)
    end
  end

  def self.down
    Word.all.each do |word|
      word.update_attribute(:name, word.name.titleize)
    end
  end
end
