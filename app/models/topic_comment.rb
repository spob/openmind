class TopicComment < Comment
  belongs_to :topic, :counter_cache => true
  
  validates_presence_of :topic_id
  
  def can_edit? current_user, role_override=false
    return true if role_override
    topic.last_comment?(self) and user.id == current_user.id
  end
end