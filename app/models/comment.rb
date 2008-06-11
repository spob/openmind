class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :idea
  
  validates_presence_of :user_id, :idea_id
  validates_presence_of :body
  
  def can_edit? current_user, role_override=false
    return true if role_override
    idea.last_comment?(self) and user.id == current_user.id
  end
end