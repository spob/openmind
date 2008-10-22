# == Schema Information
# Schema version: 20081021172636
#
# Table name: announcements
#
#  id           :integer(4)      not null, primary key
#  headline     :string(120)     not null
#  description  :text
#  lock_version :integer(4)      default(0)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  textiled     :boolean(1)      not null
#

class Announcement < ActiveRecord::Base
  validates_presence_of :headline, :description
  validates_length_of :headline, :maximum => 80
  
  xss_terminate :except => [:description]
  
  def self.list(page, per_page, limit = :all)
    paginate :page => page, 
      :order => 'announcements.created_at DESC' ,
      :limit => limit,
      :per_page => per_page
  end
  
  def can_delete?
    true
  end
  
  def can_edit?
    true
  end
  
  def formatted_description
    r = RedCloth.new description
    r.to_html
  end
  
  def unread? user
    return true if user.last_message_read.nil?
    user.last_message_read < created_at
  end
end
