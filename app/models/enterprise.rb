# == Schema Information
# Schema version: 20081021172636
#
# Table name: enterprises
#
#  id                 :integer(4)      not null, primary key
#  name               :string(50)      not null
#  active             :boolean(1)      default(TRUE), not null
#  lock_version       :integer(4)      default(0)
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  enterprise_type_id :integer(4)
#

class Enterprise < ActiveRecord::Base
  #  acts_as_solr :fields => [:name]
  define_index do
    indexes name, :sortable => true
    
    has created_at, updated_at
    set_property :delta => true
  end
  
  validates_presence_of :name #, :active
  validates_uniqueness_of :name, :case_sensitive => false
  validates_length_of :name, :maximum => 50
  
  before_create :default_view_portal
  
  # to allow user to create an allocation at the same time they create an
  # enterprise
  attr_accessor :initial_allocation 
  
  has_many :users, :dependent => :destroy, :order => "email ASC"   
  has_many :allocations, :dependent => :destroy, :order => "created_at ASC"  
  #  has_many :active_allocations, :conditions => ["expiration_date > ?", Date.current.to_s(:db)],
  #    :order => "created_at ASC"
  has_many :votes, :through => :allocations, :order => "votes.id ASC"
  belongs_to :enterprise_type
  
  named_scope :active, :conditions => {:active => true}, :order => "name ASC"
  named_scope :next,
  lambda{|name|{:conditions => ['name > ?', name],
      :order => 'name',
      :limit => 1}}
  named_scope :previous,
  lambda{|name|{:conditions => ['name < ?', name],
      :order => 'name desc',
      :limit => 1}}
  
  def self.list(page, per_page, start_filter, end_filter, ids)
    conditions = []
    unless start_filter == 'All'
      conditions << "name >= ? and name <= ?"
      conditions << start_filter
      conditions << end_filter
    end
    unless ids.nil?
      conditions << "id in (?)"
      conditions << ids
    end
    paginate :page => page, :order => 'name', 
    :per_page => per_page,
    :conditions => conditions
  end
  
  def can_delete?
    users.empty? and allocations.empty?
  end  
  
  def available_votes
    enterprise_allocations = 0
    for allocation in allocations.active
      enterprise_allocations += allocation.quantity - allocation.votes.size
    end
    enterprise_allocations
  end
  
  private
  
  def default_view_portal
    default_view = APP_CONFIG['new_enterprises_view_portal_default']
    self.view_portal = (default_view && "Y" == default_view)   
  end
end
