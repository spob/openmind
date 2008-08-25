class Forum < ActiveRecord::Base
  has_many :topics, :order => "pinned DESC, updated_at DESC", :dependent => :delete_all
  has_and_belongs_to_many :mediators, :join_table => 'forum_mediators', 
    :class_name => 'User'     
  has_and_belongs_to_many :watchers, :join_table => 'forum_watches', :class_name => 'User'
  has_and_belongs_to_many :groups
  has_many :comments, :through => :topics, :order => "id DESC"
  
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
  
  def can_edit? user
    mediators.include? user
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
    puts "========================="
    puts "Group: (#{id}) #{name}"
    can_edit? user or groups.empty? or !groups.select{|group| group.users.include? user}.empty?
  end
end