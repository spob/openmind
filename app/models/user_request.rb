class UserRequest < ActiveRecord::Base
  validates_presence_of     :email, :last_name, :enterprise_name
  validates_length_of       :email,    :within => 3..100
  validates_email_format_of :email
  validates_length_of       :first_name, :maximum => 40, :allow_nil => true
  validates_length_of       :last_name, :maximum => 40, :allow_nil => true
  validates_numericality_of :initial_enterprise_allocation, :only_integer => true, 
    :allow_nil => false, :greater_than_or_equal_to => 0
  validates_numericality_of :initial_user_allocation, :only_integer => true, 
    :allow_nil => false, :greater_than_or_equal_to => 0
  
  belongs_to :enterprise  
  
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
  
  def self.list(page, per_page, statuses, limit = :all)
    paginate :page => page, 
      :conditions => ["status in (?)", statuses],
      :order => 'created_at DESC' ,
      :limit => limit,
      :per_page => per_page
  end
  
  def can_delete?
    status == UserRequest.pending
  end

  protected

  def validate
    # won't be necessary with rails 2.0 with improved validate_numericality
    errors.add("initial_enterprise_allocation", "must be > 0") if initial_enterprise_allocation < 0
    errors.add("initial_user_allocation", "must be > 0") if initial_user_allocation < 0
  end
end