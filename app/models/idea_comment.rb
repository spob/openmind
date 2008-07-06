class IdeaComment < Comment
  belongs_to :idea
  
  validates_presence_of :idea_id
  
  def can_edit? current_user, role_override=false
    return true if role_override
    idea.last_comment?(self) and user.id == current_user.id
  end
end