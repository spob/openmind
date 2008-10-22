# == Schema Information
# Schema version: 20081021172636
#
# Table name: watches
#
#  user_id      :integer(4)      not null
#  idea_id      :integer(4)      not null
#  lock_version :integer(4)      default(0)
#  created_at   :datetime        not null
#

class Watch < ActiveRecord::Base
  belongs_to :user
  belongs_to :idea

  validates_presence_of :user_id
  validates_presence_of :idea_id

end
