class ReleaseStatus < LookupCode  
  has_many :releases,
    :dependent => :destroy
  
  def can_delete?
    releases.empty?
  end
end
