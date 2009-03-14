# == Schema Information
# Schema version: 20081021172636
#
# Table name: allocations
#
#  id              :integer(4)      not null, primary key
#  quantity        :integer(4)      default(0), not null
#  comments        :text
#  user_id         :integer(4)
#  enterprise_id   :integer(4)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  lock_version    :integer(4)      default(0)
#  allocation_type :string(30)      not null
#  expiration_date :date            default(Tue, 20 Jan 2009), not null
#

class Allocation < ActiveRecord::Base
  has_many :votes,  :dependent => :destroy, :order => "id asc"     
  
  validates_presence_of :quantity, :expiration_date
  validates_length_of :comments, :maximum => 255
  validates_numericality_of :quantity, :only_integer => true, 
    :allow_nil => false, :minimum => 1
  
  named_scope :active, 
    lambda{{:conditions => ['expiration_date >= ?', (Date.current).to_s(:db)],
      :order => 'expiration_date asc'}}
  
  def self.inheritance_column
    'allocation_type'
  end
  
  def available_quantity
    quantity - votes.size
  end
  
  def self.expiring_allocation_days(user)
    min(first_expiration_days(user.allocations.active), 
      first_expiration_days(user.enterprise.allocations.active))
  end
  
  def self.list_all_for_user(user, page, per_page, active_only)
    paginate :page => page, 
      :conditions => ["(allocation_type = 'UserAllocation' and allocations.user_id = ?) or (allocation_type = 'EnterpriseAllocation' and enterprise_id = ?) and expiration_date > ?",
      user.id, user.enterprise.id,
     (active_only ? DateUtils.today_utc : 10.years.ago)],
      :order => 'allocations.created_at DESC,  allocations.enterprise_id ASC, allocations.user_id  ASC' ,
      :per_page => per_page, :include => :votes
  end

  def self.list(user, enterprise, must_filter, page, per_page, active_only)
    where = ""
    where += "(allocation_type = 'UserAllocation' and allocations.user_id = ?)" unless user.nil?
    where += " or " unless user.nil? or enterprise.nil?
    where += "(allocation_type = 'EnterpriseAllocation' and enterprise_id = ?)" unless enterprise.nil?
    where = "(#{where})" unless user.nil? and enterprise.nil?
    where += " and "  unless (user.nil? and enterprise.nil?) or !active_only
    where += "expiration_date > ?" if active_only
    where = "(true)" if user.nil? and enterprise.nil? and !active_only
    where = "(false)" if user.nil? and enterprise.nil? and must_filter
    conditions = []
    conditions << where
    conditions << user.id unless user.nil?
    conditions << enterprise.id unless enterprise.nil?
    conditions << DateUtils.today_utc if active_only
    paginate :page => page, 
      :conditions => conditions,
#      :conditions => [where, 
#      	(active_only ? DateUtils.truncate_datetime(DateTime.now) : 10.years.ago)],
      :order => 'allocations.created_at DESC,  allocations.enterprise_id ASC, allocations.user_id  ASC' ,
      :per_page => per_page, :include => :votes
  end

  def can_delete?
    votes.empty?
  end
  
  def self.calculate_expiration_date
    Date.jd(DateUtils.today_utc.jd + APP_CONFIG['allocation_expiration_days'].to_i)
  end
  
  private
  
  def self.first_expiration_days(allocations)
    today_jd = DateUtils.today_utc.jd
    #    puts "today: #{DateUtils.today_utc}, #{today_jd}"
    expiring_days = 9999
    if !allocations.nil?
      for allocation in allocations
        if allocation.available_quantity > 0
#          puts "allocation: #{allocation.expiration_date}, #{allocation.expiration_date.jd}, #{allocation.expiration_date.jd - today_jd}"
          l_expiring_days = allocation.expiration_date.jd - today_jd
          if l_expiring_days < expiring_days and l_expiring_days >= 0
            expiring_days = l_expiring_days
          end          
        end
      end
    end
    expiring_days
  end
  
  def self.min(val1, val2)
    return val1 if val1 < val2
    val2
  end

  protected 
  def validate
    errors.add(:quantity, "should be at least 1 or greater") if quantity.nil?  || quantity < 1
    errors.add(:quantity, "must be greater than the votes used, which is #{votes.size}") if quantity < votes.size
  end
end
