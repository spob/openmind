class Enterprise < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name 
  validates_length_of :name, :maximum => 50
  
  attr_accessor :initial_allocation # to allow user to create an allocation at the
                                    # same time they create an enterprise
  
  has_many :users,:dependent => :destroy, :order => "email ASC"   
  has_many :allocations,:dependent => :destroy, :order => "created_at ASC"  
  has_many :active_allocations, :conditions => ["expiration_date > ?", DateTime.now.to_s(:db)], 
    :order => "created_at ASC"   
  has_many :votes, :through => :allocations, :order => "votes.id ASC"
  
  def self.list(page, per_page, start_filter, end_filter)
    paginate :page => page, :order => 'name', 
      :per_page => per_page,
      :conditions => ["(name >= ? and name <= ?) or ? = 'All'",
      start_filter, end_filter, start_filter
    ]
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
    enterprise_allocations = 0
    for allocation in active_allocations
      enterprise_allocations += allocation.quantity - allocation.votes.size
    end
    enterprise_allocations
  end


  def self.active_enterprises
    Enterprise.find_all_by_active(true, :order => "name")
  end
end