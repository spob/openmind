class TrainingGroup < ActiveRecord::Base
  validates_presence_of :email, :group_name
  validates_length_of :email, :maximum => 50
  
  named_scope :unprocessed,
  :conditions => { :processed_at => nil }
end
