# == Schema Information
# Schema version: 20081021172636
#
# Table name: topic_watches
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)      not null
#  topic_id        :integer(4)      not null
#  lock_version    :integer(4)      default(0)
#  created_at      :datetime        not null
#  last_checked_at :datetime        default(Mon Sep 22 23:09:27 UTC 2008), not null
#

# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

class TopicWatch < ActiveRecord::Base
  belongs_to :watcher, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :topic
end