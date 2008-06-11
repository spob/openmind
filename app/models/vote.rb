class Vote < ActiveRecord::Base
  
  belongs_to :idea
  belongs_to :allocation
  belongs_to :user
  
  validates_presence_of :user_id, :allocation_id, :idea_id

  def self.list(page, per_page, enterprise_id = nil, user_id = nil)
    conditions = []
    enterprise_where = " exists (select null from allocations as a where a.id = votes.allocation_id and a.enterprise_id = ?)"
    user_where = " exists (select null from allocations as a where a.id = votes.allocation_id and a.user_id = ?)"
    if enterprise_id.nil? and user_id.nil?
      conditions[0] = "true"
    elsif  !enterprise_id.nil? and user_id.nil?
      conditions[0] = enterprise_where
      conditions[1] = enterprise_id
    elsif  enterprise_id.nil? and !user_id.nil?
      conditions[0] = user_where
      conditions[1] = user_id
    elsif  !enterprise_id.nil? and !user_id.nil?
      conditions[0] = "(#{enterprise_where}) or (#{user_where})"
      conditions[1] = enterprise_id
      conditions[2] = user_id
    end
    
    paginate :page => page, 
      :conditions => conditions,
      :order => 'votes.created_at DESC', 
      :per_page => per_page,
      :include => :idea
  end

  def can_delete?
    true
  end

  # The number of seconds until a vote can no longer be rescinded  
  def self.rescind_seconds
    APP_CONFIG['rescind_minutes'].to_i * 60
  end
end