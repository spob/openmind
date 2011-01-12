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
#  acts_as_solr :fields => [:body, {:created_at => :date}]

  define_index do
    indexes body
    has created_at, updated_at
    set_property :delta => true
  end

  belongs_to :topic, :counter_cache => true
  belongs_to :endorser, :class_name => 'User'
  before_create :update_topic_commented_at_on_create
  before_create :notify_immediate_watchers
  before_update :update_topic_commented_at_on_update

  validates_presence_of :topic_id

  named_scope :by_user,
    lambda{|user|{:conditions => ['comments.user_id = ?', user.id]}}
  named_scope :by_moderator, :joins => {:topic => { :forum => :mediators }},
    :conditions => [ "comments.user_id = forum_mediators.user_id" ]
  named_scope :topic_ids, :select => ["comments.topic_id"]

  def update_topic_commented_at_on_create
    unless private
      self.topic.update_attribute(:last_commented_at, Time.zone.now)
      self.published_at = Time.zone.now
    end
  end

  def update_topic_commented_at_on_update
    update_topic_commented_at_on_create if !private and published_at.nil?
  end

  def can_see? current_user
    !self.private or topic.forum.mediators.include? current_user
  end

  def can_edit? current_user, role_override=false
    return true if role_override
    (topic.last_comment?(self) and user.id == current_user.id) or
      topic.forum.mediators.include? current_user
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

  def self.top_users forum=nil
    sql = %Q{
        select u.id, u.first_name, u.last_name, u.email, u.hide_contact_info, count(*)
        from users as u
        inner join comments as c on u.id = c.user_id
        inner join topics as t on t.id = c.topic_id
        where c.type = 'TopicComment'
          and t.forum_id = ? or ? = -1
        group by u.id, u.first_name, u.last_name, u.email, u.hide_contact_info
        order by count(*) desc
        limit 5
    }
    forum_id = (forum.nil? ? -1 : forum.id)
    User.find(:all, :conditions => ["id in (?)",
        User.find_by_sql([sql, forum_id, forum_id]).collect(&:id)]).sort_by{|u| u.topic_comments.size * -1}
  end

  def rss_headline
    "Forum: #{topic.forum.name}, Topic: #{topic.title}"
  end

  def rss_body
    "<i>#{user.display_name} wrote:</i><br/>#{body}"
  end

  private

  def notify_immediate_watchers
      RunOncePeriodicJob.create(
      	:job => "Topic.notify_immediate_watchers(#{self.topic.id})")
  end
end
