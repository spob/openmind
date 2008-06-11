class Role < ActiveRecord::Base
  validates_presence_of :title, :description
  validates_uniqueness_of :title
  validates_uniqueness_of :description
  validates_length_of :title, :maximum => 50
  validates_length_of :description, :maximum => 50
  
  has_and_belongs_to_many :users 
  
  def self.list(page)
    paginate :page => page, :order => 'description', 
      :per_page => 10
  end
  
  def self.list
    Role.find(:all, :order => "description ASC" )
  end

  def can_delete?
    return false
  end  
end
