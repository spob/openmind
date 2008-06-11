class Enterprise < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name 
  validates_length_of :name, :maximum => 50
  
  has_many :users,:dependent => :destroy    
  has_many :allocations,:dependent => :destroy    
  has_many :votes, :through => :allocations
  
  def self.list(page, per_page)
    paginate :page => page, :order => 'name', 
      :per_page => per_page
  end
  
  def self.active_enterprises
    Enterprise.find_all_by_active(true, :order => "name ASC")
  end
  
  def active_allocations
    allocations.find(:all, 
      :conditions => ['expiration_date >= ?', (Date.today).to_s(:db)],
      :order => 'expiration_date asc')
  end
  
  def active_users 
    users.find(:all, :conditions => [ "active = ? and activated_at is not null", true])
  end

  def can_delete?
    users.empty? and allocations.empty?
  end  
  
  def available_votes
    enterprise_allocations = allocations.sum(:quantity)
    enterprise_allocations ||= 0
    
    enterprise_allocations - votes.size
  end


  def self.active_enterprises
    Enterprise.find_all_by_active(true, :order => "name")
  end
end