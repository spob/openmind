class Topic < ActiveRecord::Base
  belongs_to :forum
  belongs_to :user
  has_and_belongs_to_many :mediators, :join_table => 'forum_mediators', :class_name => 'User'
  has_many :comments, :dependent => :destroy , :order => "id ASC"   
  has_one :last_comment, :class_name => "TopicComment", :order => "id DESC"
  
  validates_presence_of :title, :user
  validates_length_of   :title, :maximum => 120
  
  attr_accessor :comment_body
  
  def can_delete?
    true
  end
  
  def self.list(page, per_page)
    paginate :page => page, :order => 'title ASC', 
      :per_page => per_page
  end
  
  def last_comment? comment
    return false if last_comment.nil?
    comment.id == last_comment.id
  end
end
