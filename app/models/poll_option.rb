# == Schema Information
# Schema version: 20081021172636
#
# Table name: poll_options
#
#  id           :integer(4)      not null, primary key
#  description  :string(80)      not null
#  poll_id      :integer(4)      not null
#  lock_version :integer(4)      default(0)
#  created_at   :datetime        not null
#  selectable   :boolean(1)      default(TRUE), not null
#  updated_at   :datetime        not null
#

class PollOption < ActiveRecord::Base
  validates_presence_of :description
  validates_length_of :description, :maximum => 120
  validates_uniqueness_of :description, :scope => "poll_id"
  
  belongs_to :poll
  has_and_belongs_to_many :user_responses, :join_table => 'poll_user_responses', :class_name => 'User'
  
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def percent_chosen
    total = poll.total_responses
    return 0 if total == 0
    return (user_responses.size.to_f/total.to_f) * 100
  end
end
