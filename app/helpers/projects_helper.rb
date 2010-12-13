module ProjectsHelper
  def day_headings project
    (1..project.latest_iteration.calc_day_number).collect { |d| "<th>#{d}</th>" }.join
  end

  def task_estimate_for_day task, day_number
    @estimate = task.task_estimates.find_by_as_of(task.story.iteration.calc_date day_number)
    if @estimate
      @estimate.remaining_hours
    else
      "-"
    end
  end
end
