# == Schema Information
# Schema version: 20081021172636
#
# Table name: forums
#
#  id           :integer(4)      not null, primary key
#  name         :string(50)      not null
#  description  :string(150)     not null
#  lock_version :integer(4)      default(0)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  active       :boolean(1)      default(TRUE), not null
#  link_set_id  :integer(4)
#

class Forum < ActiveRecord::Base
  has_many :topics, :order => "pinned DESC, last_commented_at DESC", :dependent => :delete_all
  has_and_belongs_to_many :mediators, :join_table => 'forum_mediators', 
  :class_name => 'User', :order => 'email'
  has_and_belongs_to_many :watchers, :join_table => 'forum_watches', :class_name => 'User'
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :enterprise_types
  has_many :comments, :through => :topics
  has_many :comments_by_topic, :source => 'comments', :through => :topics, :order => "topic_id ASC, id ASC"
  belongs_to :link_set
  belongs_to :forum_group
  belongs_to :power_user_group, :class_name => "Group", :foreign_key => :power_user_group_id
  
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_presence_of :description
  validates_length_of   :name, :maximum => 50
  validates_length_of   :description, :maximum => 150
  validates_numericality_of :display_order, :only_integer => true, :allow_nil => true
  
  
  named_scope :active,
  :conditions => [ "active = ?", true]
  
  named_scope :tracked,
  :conditions => [ "tracked = ?", true]
  
  named_scope :order_by_name,
  :order => 'name asc'
  
  named_scope :limit1,
  :limit => '1'
  
  has_friendly_id :name, :use_slug => true
  
  def can_delete?
    topics.empty?
  end
  
  def self.list(page, per_page)
    paginate :page => page, :order => 'name ASC', 
    :per_page => per_page
  end
  
  def self.list_by_forum_group forum_group=nil
    return Forum.find(:all,
                      :conditions => ["forum_group_id is null"],
    :include => [:topics],
    :order => 'display_order ASC, name ASC') if forum_group.nil?
    Forum.find_all_by_forum_group_id(forum_group.id,
                                     :include => [:topics],
                                     :order => 'display_order ASC, name ASC')
  end
  
  def self.list_visible user
    Forum.find(:all, :order => 'name ASC').find_all{|f| f.can_see? user}
  end
  
  def can_edit? user
    mediators.include? user or (user != :false and (user.prodmgr? or user.sysadmin?))
  end 
  
  # Return a list of topics for this forum that have comments which have not yet
  # been read by the specified user
  def unread_topics user
    topics.find_all{|topic| topic.unread_comment?(user) }
  end
  
  def watch_all_topics user
    for topic in topics
      topic.watchers << user unless topic.watchers.include? user
      topic.save
    end
  end
  
  def remove_all_topic_watches user
    for topic in topics
      topic.watchers.delete(user) if topic.watchers.include? user
      topic.save
    end
  end
  
  def self.notify_pending_topics
     Topic.owned.open.tracked(:select => 'distinct owner_id').find_all{|t| t.days_comment_pending > 0}.collect(&:owner).uniq.each do |u|
       EmailNotifier.deliver_pending_topics u.owned_topics.open.tracked if u.active
     end
  end
  
  def mark_all_topics_as_read user
    Topic.transaction do
      for topic in topics
        topic.add_user_read user, false
      end
    end
  end
  
  def power_user? user
    return false if power_user_group.nil?
    power_user_group.users.include? user
  end
  
  def mediator? user
    mediators.include? user
  end
  
  def public?
    self.groups.empty? and self.enterprise_types.empty?
  end
  
  def can_see? user
    return true if user != :false and (user.prodmgr? or user.sysadmin?)
    can_edit? user or 
     (((public?) or
    !groups.select{|group| group.users.include? user}.empty? or
    !enterprise_types.select{|enterprise_type| enterprise_type.users.include? user}.empty?) and active)
  end
  
  def can_create_topic? user
    user != :false and (!restrict_topic_creation or can_edit? user)
  end
  
  def restrict_topic_creation
    self.forum_type == 'blog' or self.forum_type == 'announcement'
  end
  
  def restrict_comment_creation
    self.forum_type == 'announcement'
  end
  
  protected
  def validate
    errors.add(:forum_type, 
      "should be either 'forum', 'blog' or 'announcement'") unless self.forum_type == 'forum' or
    self.forum_type == 'blog' or self.forum_type == 'announcement'
  end
end
