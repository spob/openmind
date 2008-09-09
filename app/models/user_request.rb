class UserRequest < ActiveRecord::Base
  validates_presence_of     :email, :last_name, :enterprise_name
  validates_length_of       :email,    :within => 3..100
  validates_email_format_of :email
  validates_length_of       :first_name, :maximum => 40, :allow_nil => true
  validates_length_of       :last_name, :maximum => 40, :allow_nil => true
  
  def self.pending
    "Pending"
  end
  
  def self.rejected
    "Rejected"
  end
  
  def self.approved
    "Approved"
  end
  
  def self.list(page, per_page, limit = :all)
    paginate :page => page, 
      :order => 'created_at DESC' ,
      :limit => limit,
      :per_page => per_page
  end
  
  def can_delete?
    status == UserRequest.pending
  end
end
