class Watch < ActiveRecord::Base
  belongs_to :user
  belongs_to :idea

  validates_presence_of :user_id
  validates_presence_of :idea_id

end