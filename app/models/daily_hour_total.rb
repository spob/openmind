class DailyHourTotal < ActiveRecord::Base
  belongs_to :iteration

  validates_uniqueness_of :as_of, :scope => :iteration_id
  validates_presence_of :as_of
  validates_presence_of :total_hours
  validates_presence_of :remaining_hours
  validates_presence_of :velocity

  named_scope :before_date,
    lambda{|the_date|{:conditions => ["as_of <= ?", the_date]}}
end