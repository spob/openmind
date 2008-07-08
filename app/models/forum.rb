class Forum < ActiveRecord::Base
  validates_presence_of :name
  validates_length_of   :name, :maximum => 50
  
  def can_delete?
    true
  end
  
  def self.list(page, per_page)
    paginate :page => page, :order => 'name ASC', 
      :per_page => per_page
  end
end
