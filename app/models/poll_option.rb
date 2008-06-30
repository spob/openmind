class PollOption < ActiveRecord::Base
  validates_presence_of :description
  validates_length_of :description, :maximum => 120
  
  has_and_belongs_to_many :user_responses, :join_table => 'poll_user_responses', :class_name => 'User'
  
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end
end
