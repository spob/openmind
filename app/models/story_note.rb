class StoryNote < ActiveRecord::Base
  belongs_to :story, :class_name => "Story"
  validates_numericality_of :pivotal_identifier, :greater_than_or_equal_to => 1, :only_integer => true, :allow_nil => true
  validates_uniqueness_of :pivotal_identifier, :case_sensitive => false, :scope => :story_id
  validates_presence_of :noted_at, :comment, :author, :defect_id, :story_id, :pivotal_identifier
end
