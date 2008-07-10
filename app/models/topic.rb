class Topic < ActiveRecord::Base
  belongs_to :forum
  belongs_to :user
  has_many :comments, :dependent => :delete_all , :order => "id ASC"   
  has_one :last_comment, :class_name => "TopicComment", :order => "id DESC"
  has_one :main_comment, :class_name => "TopicComment", :order => "id ASC"
  
  validates_presence_of :title, :user
  validates_length_of   :title, :maximum => 120
  
  attr_accessor :comment_body
  
  def can_delete?
    comments.count <= 1
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
