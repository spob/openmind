# == Schema Information
# Schema version: 20081021172636
#
# Table name: user_idea_reads
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)      not null
#  idea_id      :integer(4)      not null
#  last_read    :datetime        default(Mon Sep 22 23:09:23 UTC 2008), not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer(4)      default(0)
#

class UserIdeaRead < ActiveRecord::Base
  belongs_to :user
  belongs_to :idea
end
