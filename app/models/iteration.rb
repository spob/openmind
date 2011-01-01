class Iteration < ActiveRecord::Base
  belongs_to :project
  has_many :stories, :dependent => :destroy
  has_many :tasks, :through => :stories
  has_many :task_estimates, :conditions => {:task_id => nil}, :order => "as_of", :dependent => :destroy
  has_one :latest_estimate, :class_name => "TaskEstimate", :conditions => {:task_id => nil}, :order => "as_of DESC"

  validates_presence_of :iteration_number
  validates_presence_of :start_on
  validates_presence_of :end_on
  validates_uniqueness_of :iteration_number, :case_sensitive => false, :scope => :project_id
  validates_numericality_of :iteration_number, :greater_than_or_equal_to => 1, :only_integer => true, :allow_nil => true

  named_scope :by_iteration_number,
              lambda { |num| {:conditions => {:iteration_number => num}} }
  named_scope :lock, :lock=> true

  def iteration_name
    "Iteration #{self.iteration_number}"
  end

  def remaining_hours_for_day_number day_number
    @estimate = fetch_estimate_by_day_number day_number
    (@estimate ? @estimate.remaining_hours : 0.0)
  end

  def total_hours_for_day_number day_number
    @estimate = fetch_estimate_by_day_number day_number
    (@estimate ? @estimate.total_hours : 0.0)
  end

  def velocity_for_day_number day_number
    @estimate = fetch_estimate_by_day_number day_number
    (@estimate ? @estimate.velocity : 0)
  end

  def points_delivered_for_day_number day_number
    @estimate = fetch_estimate_by_day_number day_number
    (@estimate ? @estimate.points_delivered : 0)
  end

  def total_hours
    self.tasks.not_pushed.sum('total_hours')
  end

  def remaining_hours
    self.tasks.sum('remaining_hours')
  end

  def total_points
    self.stories.pointed.sum('points')
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

  def calc_day_number the_date=Project.calculate_project_date
    the_date = end_on - 1 if the_date > end_on - 1
    day_num = 0
    (self.start_on..the_date).each do |d|
      day_num += 1 if d.cwday < 6
    end
    day_num
  end

  @estimates = nil

  def fetch_estimate_by_day_number day_number
    fetch_estimate_by_date(self.calc_date(day_number))
  end

  def fetch_estimate_by_date the_date
    populate_estimates_hash unless @estimates
    @estimates[the_date]
  end

  def debug
    populate_estimates_hash unless @estimates
    @estimates.keys.each do |k|
      puts "#{k}: #{@estimates[k].try(:id)}"
    end
  end

  private

  def populate_estimates_hash
    @estimates = {}
    self.task_estimates.each do |e|
      @estimates[e.as_of] = e
    end
  end
end
