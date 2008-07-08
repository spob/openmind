class Forum < ActiveRecord::Base
  validates_presence_of :name
  validates_length_of   :name, :maximum => 50
  
  def can_delete?
    true
  end
end
