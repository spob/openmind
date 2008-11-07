# == Schema Information
# Schema version: 20081021172636
#
# Table name: idea_change_logs
#
#  id           :integer(4)      not null, primary key
#  idea_id      :integer(4)      not null
#  user_id      :integer(4)      not null
#  message      :text            not null
#  processed_at :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

class IdeaChangeLog < ActiveRecord::Base
  belongs_to :idea
  belongs_to :user
  
  validates_presence_of :user, :message
end
