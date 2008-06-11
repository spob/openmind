class UserAllocation < Allocation
  validates_presence_of :user_id
  
  belongs_to :user
  
  def to_s
    "User Allocation, user: #{user.email}, quantity: #{quantity}"
  end
end