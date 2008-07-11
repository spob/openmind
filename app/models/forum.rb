class Forum < ActiveRecord::Base
  has_many :topics, :order => "pinned ASC, id ASC", :dependent => :delete_all
  has_and_belongs_to_many :mediators, :join_table => 'forum_mediators', 
    :class_name => 'User'     
  has_many :comments, :through => :topics, :order => "id DESC"
  
  validates_presence_of :name
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
end
