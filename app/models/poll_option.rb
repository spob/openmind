class PollOption < ActiveRecord::Base
  validates_presence_of :description
  validates_length_of :descriptions, :maximum => 120
end
