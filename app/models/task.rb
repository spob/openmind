class Task < ActiveRecord::Base
  belongs_to :story
  has_many :task_estimates, :order => "as_of"

  named_scope :pushed,
              :conditions => {:status => "pushed"}
  named_scope :not_pushed,
              :conditions => ["tasks.status <> ?", "pushed"]

  @estimates = nil

  def fetch_estimate_by_day_number day_number, iteration=self.story.iteration
    fetch_estimate_by_date(iteration.calc_date(day_number))
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
  
  def self.sort_by_status tasks
    tasks.sort_by do |s|
      case s.status
        when "Done" then
          1
        when "In Progress" then
          2
        when "Not Started" then
          3
        else
          7
      end
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
