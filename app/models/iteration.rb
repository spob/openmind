class Iteration < ActiveRecord::Base
  belongs_to :project
  has_many :stories
  has_many :tasks, :through => :stories
  has_many :daily_hour_totals, :order => "as_of"

  validates_presence_of :iteration_number
  validates_presence_of :start_on
  validates_presence_of :end_on
  validates_uniqueness_of :iteration_number, :case_sensitive => false, :scope => :project_id
  validates_numericality_of :iteration_number, :greater_than_or_equal_to => 1, :only_integer => true, :allow_nil => true

  named_scope :by_iteration_number,
    lambda{|num|{:conditions => { :iteration_number => num}}}

  def total_hours
    self.tasks.sum('total_hours')
  end

  def remaining_hours
    self.tasks.sum('remaining_hours')
  end

  def total_points
    self.stories.sum('points')
  end

  def total_points_delivered
    self.stories.accepted.sum('points')
  end

  def calc_day_number the_date=Date.current
    self.daily_hour_totals.before_date(the_date).count
  end
end
