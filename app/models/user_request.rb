# == Schema Information
# Schema version: 20081021172636
#
# Table name: user_requests
#
#  id                            :integer(4)      not null, primary key
#  email                         :string(255)     not null
#  created_at                    :datetime
#  updated_at                    :datetime
#  first_name                    :string(255)
#  last_name                     :string(255)     not null
#  lock_version                  :integer(4)      default(0)
#  enterprise_name               :string(255)     not null
#  enterprise_id                 :integer(4)
#  initial_enterprise_allocation :integer(4)      default(0), not null
#  initial_user_allocation       :integer(4)      default(0), not null
#  time_zone                     :string(255)     not null
#  status                        :string(10)      not null
#

class UserRequest < ActiveRecord::Base  
  acts_as_ordered :order => 'id DESC' 
  validates_presence_of     :email, :last_name, :enterprise_name, :time_zone, :status
  validates_length_of       :email,    :within => 3..100
  validates_email_format_of :email
  validates_length_of       :first_name, :maximum => 40, :allow_nil => true
  validates_length_of       :last_name, :maximum => 40, :allow_nil => true
  validates_numericality_of :initial_enterprise_allocation, :only_integer => true, 
    :allow_nil => false, :greater_than_or_equal_to => 0
  validates_numericality_of :initial_user_allocation, :only_integer => true, 
    :allow_nil => false, :greater_than_or_equal_to => 0
  
  belongs_to :enterprise
  belongs_to :enterprise_type
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :roles
  
  attr_accessor :enterprise_action
  
  def self.pending
    "Pending"
  end
  
  def self.rejected
    "Rejected"
  end
  
  def self.approved
    "Approved"
  end
  
  def self.pending_requests?
    !UserRequest.find_by_status(pending).nil?
  end
  
  def self.list(page, per_page, statuses, limit = :all)
    paginate :page => page, 
      :conditions => ["status in (?)", statuses],
      :order => 'id DESC' ,
      :limit => limit,
      :per_page => per_page
  end
  
  def self.send_confirmation_email id
    request = UserRequest.find(id)
    if request.email_sent.nil?
      EmailNotifier.deliver_user_request_received_notification id
      request.update_attribute(:email_sent, Time.zone.now)
    end
  end
  
  def can_delete?
    status == UserRequest.pending
  end
  
  def before_validation_on_create
    self.status = UserRequest.pending
  end

  protected

  def validate
    # won't be necessary with rails 2.0 with improved validate_numericality
    errors.add("initial_enterprise_allocation", "must be > 0") if initial_enterprise_allocation < 0
    errors.add("initial_user_allocation", "must be > 0") if initial_user_allocation < 0
  end
  
end
