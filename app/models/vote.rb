# == Schema Information
# Schema version: 20081021172636
#
# Table name: votes
#
#  id            :integer(4)      not null, primary key
#  user_id       :integer(4)      not null
#  allocation_id :integer(4)
#  idea_id       :integer(4)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  lock_version  :integer(4)      default(0)
#  comments      :text
#

class Vote < ActiveRecord::Base

  belongs_to :idea
  belongs_to :allocation
  belongs_to :user

  named_scope :include_idea, :include => [:idea]

  validates_presence_of :user_id, :allocation_id, :idea_id

  def self.list(page, per_page, enterprise = nil, user = nil)
    conditions = []
    enterprise_where = "votes.user_id in (select u.id from users as u where u.enterprise_id = ?)"
    user_where = "votes.user_id = ?"
    if enterprise.nil? and user.nil?
      conditions[0] = "true"
    elsif  !enterprise.nil? and user.nil?
      conditions[0] = enterprise_where
      conditions[1] = enterprise.id
    elsif  enterprise.nil? and !user.nil?
      conditions[0] = user_where
      conditions[1] = user.id
    elsif  !enterprise.nil? and !user.nil?
      conditions[0] = "(#{enterprise_where}) or (#{user_where})"
      conditions[1] = enterprise.id
      conditions[2] = user.id
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
