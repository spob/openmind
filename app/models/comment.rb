# == Schema Information
# Schema version: 20081021172636
#
# Table name: comments
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)      not null
#  idea_id      :integer(4)
#  body         :text
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer(4)      default(0)
#  type         :string(255)     not null
#  topic_id     :integer(4)
#  textiled     :boolean(1)      not null
#

class Comment < ActiveRecord::Base
  belongs_to :user, :counter_cache => true
  has_many :comment_attachments, :dependent => :destroy
  
  validates_presence_of :user_id
  validates_presence_of :body
  
  xss_terminate :except => [:body]

  named_scope :private, :conditions => {:private => true}
  named_scope :public, :conditions => {:private => false}
  named_scope :most_recent, :order => "published_at DESC", :limit => 1
  
  def can_edit? current_user, role_override=false
    true
  end

  def endorsed?
    false
  end

  def can_endorse? current_user
    false
  end

  def can_unendorse? current_user
    false
  end
end
