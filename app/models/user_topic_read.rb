# == Schema Information
# Schema version: 20081021172636
#
# Table name: user_topic_reads
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)      not null
#  topic_id     :integer(4)      not null
#  lock_version :integer(4)      default(0)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  views        :integer(4)      default(0), not null
#

class UserTopicRead < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user
  
  validates_presence_of :views
end
