# == Schema Information
# Schema version: 20081008013631
# 
# Table name: enterprises
# 
#  id           :integer(4)      not null, primary key
#  name         :string(50)      not null
#  active       :boolean(1)      default(TRUE), not null
#  lock_version :integer(4)      default(0)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
# 

class Enterprise < ActiveRecord::Base
  acts_as_ordered :order => 'name' 
  
  validates_presence_of :name
  validates_uniqueness_of :name 
  validates_length_of :name, :maximum => 50
  
  # to allow user to create an allocation at the same time they create an
  # enterprise
  attr_accessor :initial_allocation 
  
  has_many :users, :dependent => :destroy, :order => "email ASC"   
  has_many :allocations, :dependent => :destroy, :order => "created_at ASC"  
  has_many :active_allocations, :conditions => ["expiration_date > ?", Date.current.to_s(:db)], 
    :order => "created_at ASC"   
  has_many :votes, :through => :allocations, :order => "votes.id ASC"
  belongs_to :enterprise_type
  
  def self.list(page, per_page, start_filter, end_filter)
    paginate :page => page, :order => 'name', 
      :per_page => per_page,
      :conditions => ["(name >= ? and name <= ?) or ? = 'All'",
      start_filter, end_filter, start_filter
    ]
  end
  
  def active_allocations
    allocations.find(:all, 
      :conditions => ['expiration_date >= ?', (Date.current).to_s(:db)],
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
    Enterprise.find_all_by_active(true, :order => "name ASC")
  end
end
