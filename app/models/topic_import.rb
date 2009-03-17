# == Schema Information
# Schema version: 20081021172636
#
# Table name: topic_imports
#
#    t.string   "forum_name",    :limit => 50,  :null => false
#    t.string   "topic_title",   :limit => 200, :null => false
#    t.string   "user_email",                :null => false
#    t.text     "comment_body",                 :null => false
#    t.datetime "created_at"
#    t.datetime "updated_at"
#    t.string   "status"
#

class TopicImport < ActiveRecord::Base
  
  validates_presence_of :forum_name, :topic_title, :comment_body

  named_scope :unprocessed, :conditions => {:status => nil}

  def self.process
    for topic_import in TopicImport.unprocessed
      TopicImport.transaction do
        forum = Forum.find_by_name topic_import.forum_name
        topic = Topic.find_by_title topic_import.topic_title
        user = User.find_by_email topic_import.user_email
        if forum.nil?
          topic_import.status = "Forum not found: #{topic_import.forum_name}"
        elsif user.nil?
          topic_import.status = "User not found: #{topic_import.user_email}"
        else
          if topic.nil?
            topic = Topic.new(:title => topic_import.topic_title,
              :forum => forum,
              :user => user,
              :comment_body => topic_import.comment_body)
            topic.save!
          end
          topic.comments << TopicComment.new(:user => user,
            :body => topic_import.comment_body)
          topic_import.status = "OK"
          topic.save!
        end
        topic_import.save!
      end
    end
  end
end
