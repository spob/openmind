class Task < ActiveRecord::Base
  belongs_to :story
  has_many :task_estimates, :order => "as_of"

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

  private

  def populate_estimates_hash
    @estimates = {}
    self.task_estimates.each do |e|
      @estimates[e.as_of] = e
    end
  end
end
