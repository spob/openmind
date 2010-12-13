class TaskEstimate < ActiveRecord::Base
  belongs_to :iteration
  belongs_to :task

  validates_presence_of :as_of
  validates_presence_of :total_hours
  validates_presence_of :remaining_hours

  named_scope :before_date,
    lambda{|the_date|{:conditions => ["as_of <= ?", the_date]}}
end