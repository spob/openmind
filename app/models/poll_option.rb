class PollOption < ActiveRecord::Base
  validates_presence_of :description
  validates_length_of :description, :maximum => 120
end
