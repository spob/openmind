module ProjectsHelper
  def day_headings iteration
    (1..iteration.calc_day_number).collect { |d| "<th>#{d}</th>" }.join
  end

  def format_float(value, precision)
    if value
      "%.#{precision}f" % value
    end
  end

  def task_estimate_for_day estimate
    (estimate && estimate.status != "pushed" ? '%.2f' % estimate.remaining_hours : "-")
  end

  def cell_color_by_task_status task
    case task.status
      when "Done" then
        bgcolor "#B2EDAF"
      when "In Progress" then
        bgcolor "#F5F4AB"
      when "Blocked" then
        bgcolor "#FF7373"
      else
        " "
    end
  end

  def cell_color_by_story_status story
    style = "border: 2px solid grey;"
    case story.status
      when "accepted" then
        bgcolor "#B2EDAF", style
      when "delivered" then
        bgcolor "#66CCFF", style
      when "finished" then
        bgcolor "#FFCC33", style
      when "rejected" then
        bgcolor "#FF7373", style
      when "started" then
        bgcolor "#F5F4AB", style
      else
        "style=\"#{style}\""
    end
  end

  def cell_color_by_hours estimate, story=estimate.task.story
    if estimate && ((estimate.total_hours > 0.0 && estimate.remaining_hours != estimate.total_hours) ||
        story.status == "accepted" || estimate.status == "Blocked") && estimate.task.status != "pushed"
      if estimate.remaining_hours == 0.0 && estimate.task.status != "pushed"
        bgcolor "#B2EDAF"
      elsif estimate.status == "Blocked"
        bgcolor "#FF7373"
      elsif estimate.remaining_hours < estimate.total_hours
        bgcolor "#F5F4AB"
      end
    else
      ""
    end
  end

  def owner_text story
    if story.owner
      "owned by #{h(story.owner)}"
    else
      "not owned"
    end
  end

  private

  def bgcolor color, other_style=""
    "style=\"background-color: #{color}; #{other_style}\""
  end
end
