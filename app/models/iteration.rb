class Iteration < ActiveRecord::Base
  belongs_to :project
  has_many :stories
  has_many :tasks, :through => :stories
  has_many :task_estimates, :conditions => { :task_id => nil }, :order => "as_of"

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

  def calc_date day_num
    the_date = self.start_on
    (2..day_num).each do
      the_date = the_date + 1
      the_date = the_date + 2 if the_date.cwday == 6
      the_date = the_date + 1 if the_date.cwday == 7
    end
    the_date
  end

  def calc_day_number the_date=Date.current
    day_num = 0
    (project.latest_iteration.start_on..the_date).each do |d|
      day_num += 1 if d.cwday < 6
    end
    day_num
  end
end
