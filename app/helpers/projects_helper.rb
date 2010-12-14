module ProjectsHelper
  def day_headings iteration
    (1..iteration.calc_day_number).collect { |d| "<th>#{d}</th>" }.join
  end

  def task_estimate_for_day estimate
    (estimate ? '%.2f' % estimate.remaining_hours : "-")
  end

  def cell_color_by_task_status task
    case task.status
      when "Done" then
        bgcolor "#B2EDAF"
      when "In Progress" then
        bgcolor "#F5F4AB"
      else
        " "
    end
  end

  def cell_color_by_story_status story
    case story.status
      when "accepted" then
        bgcolor "#B2EDAF"
      when "delivered" then
        bgcolor "#F5F4AB"
      else
        " "
    end
  end

  def cell_color_by_hours estimate,story=estimate.task.story
    if estimate && ((estimate.total_hours > 0.0 && estimate.remaining_hours != estimate.total_hours) || story.status == "accepted") && estimate.task.status != "pushed"
      if estimate.remaining_hours == 0.0
        bgcolor "#B2EDAF"
      elsif estimate.remaining_hours < estimate.total_hours
        bgcolor "#F5F4AB"
      end
    else
      ""
    end
  end

  private
  
  def bgcolor color
    "style=\"background-color: #{color}\""
  end
end
