class PollOption < ActiveRecord::Base
  validates_presence_of :description
  validates_length_of :description, :maximum => 120
  
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end
end
