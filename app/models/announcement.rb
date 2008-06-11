class Announcement < ActiveRecord::Base
  validates_presence_of :headline, :description
  validates_length_of :headline, :maximum => 80
  
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
