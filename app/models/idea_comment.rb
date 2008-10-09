# == Schema Information
# Schema version: 20081008013631
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

class IdeaComment < Comment
  belongs_to :idea
  
  validates_presence_of :idea_id
  
  def can_edit? current_user, role_override=false
    return true if role_override
    idea.last_comment?(self) and user.id == current_user.id
  end
end
