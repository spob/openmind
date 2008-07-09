class Topic < ActiveRecord::Base
  belongs_to :forum
  has_and_belongs_to_many :mediators, :join_table => 'forum_mediators', :class_name => 'User'
  
  validates_presence_of :title, :user
  validates_length_of   :title, :maximum => 120
  
  def can_delete?
    true
  end
  
  def self.list(page, per_page)
    paginate :page => page, :order => 'title ASC', 
      :per_page => per_page
  end
end
