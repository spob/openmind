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

class EnterpriseAllocation < Allocation
  validates_presence_of :enterprise_id
  
  belongs_to :enterprise
  
  def to_s
    "Enterprise Allocation, enterprise: #{enterprise.name}, quantity: #{quantity}"
  end
end
