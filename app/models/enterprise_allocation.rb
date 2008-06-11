class EnterpriseAllocation < Allocation
  validates_presence_of :enterprise_id
  
  belongs_to :enterprise
  
  def to_s
    "Enterprise Allocation, enterprise: #{enterprise.name}, quantity: #{quantity}"
  end
end