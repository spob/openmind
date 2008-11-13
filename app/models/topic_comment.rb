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

class TopicComment < Comment
  belongs_to :topic, :counter_cache => true
  belongs_to :endorser, :class_name => 'User'
  
  acts_as_indexed :fields => [ :body ]
  
  validates_presence_of :topic_id
  
  def can_edit? current_user, role_override=false
    return true if role_override
    topic.last_comment?(self) and user.id == current_user.id
  end

  def endorsed?
    !endorser.nil?
  end

  def can_endorse? current_user
    self.endorser.nil? and topic.forum.mediators.include? current_user
  end

  def can_unendorse? current_user
    !self.endorser.nil? and topic.forum.mediators.include? current_user
  end
  
  def self.top_users
    sql = %Q{
        select u.id, u.first_name, u.last_name, u.email, u.hide_contact_info, count(*)
        from users as u
        inner join comments as c on u.id = c.user_id
        where c.type = 'TopicComment'
        group by u.id, u.first_name, u.last_name, u.email, u.hide_contact_info
        order by count(*) desc
        limit 5
    }
    User.find(:all, :conditions => ["id in (?)", User.find_by_sql(sql).collect(&:id)]).sort_by{|u| u.topic_comments.size * -1}
  end
  
  def rss_headline
    "Forum: #{topic.forum.name}, Topic: #{topic.title}"
  end
  
  def rss_body
    "<i>#{user.display_name} wrote:</i><br/>#{body}"
  end
end
