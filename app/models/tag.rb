class Tag < ActiveRecord::Base
  belongs_to :entry
  belongs_to :noun, :polymorphic => true
  validates_uniqueness_of :entry_id, :scope => [:noun_id, :noun_type], :message => "Entry already has this tag."

  attr_accessor :class_size

  def self.with_class_sizes_for(tags)
    min_score = tags.map(&:score).min
    max_score = tags.map(&:score).max
    tags.shuffle
    tags.each do |tag|
      tag.class_size = quantize(tag.score, min_score, max_score)
    end
    tags
  end

  
private
  # returns a number: 1-8
  def self.quantize(score, min_score, max_score)
    score_range = (max_score == min_score) ? 1 : (max_score - min_score)
    scaling_factor = (8 - 1) / score_range
    (((score-min_score) * scaling_factor) + 1).to_i
  end  
end
