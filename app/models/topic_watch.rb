# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

class TopicWatch < ActiveRecord::Base
  belongs_to :watcher, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :topic
end
