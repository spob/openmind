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
  has_many :topics, :order => "pinned DESC, updated_at DESC", :dependent => :delete_all
  has_and_belongs_to_many :mediators, :join_table => 'forum_mediators', 
    :class_name => 'User'     
  has_and_belongs_to_many :watchers, :join_table => 'forum_watches', :class_name => 'User'
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :enterprise_types
  has_many :comments, :through => :topics, :order => "id DESC"
  belongs_to :link_set
  belongs_to :forum_group
  
  validates_presence_of :name
  validates_uniqueness_of :name 
  validates_presence_of :description
  validates_length_of   :name, :maximum => 50
  validates_length_of   :description, :maximum => 150
  
  def can_delete?
    topics.empty?
  end
  
  def self.list(page, per_page)
    paginate :page => page, :order => 'name ASC', 
      :per_page => per_page
  end
  
  def self.list_by_forum_group forum_group=nil
    return Forum.find(:all, :conditions => ["forum_group_id is null"], :order => 'name ASC') if forum_group.nil?
    Forum.find_all_by_forum_group_id(forum_group.id, :order => 'name ASC')
  end
  
  def can_edit? user
    mediators.include? user
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
  
  def can_see? user
    can_edit? user or 
      (((groups.empty? and enterprise_types.empty?) or 
          !groups.select{|group| group.users.include? user}.empty? or
          !enterprise_types.select{|enterprise_type| enterprise_type.users.include? user}.empty?) and active)
  end
end
