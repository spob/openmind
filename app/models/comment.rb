class Comment < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :user_id
  validates_presence_of :body
  
  xss_terminate :except => [:body]
  
  def can_edit? current_user, role_override=false
    true
  end
end