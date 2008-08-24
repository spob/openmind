class Group < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name 
  validates_presence_of :description
  validates_length_of   :name, :maximum => 50
  validates_length_of   :description, :maximum => 150
  
  def can_delete?
    true
  end
  
  def self.list(page, per_page)
    paginate :page => page, :order => 'name ASC', 
      :per_page => per_page
  end
  
  def can_edit? user
   true
  end
end
