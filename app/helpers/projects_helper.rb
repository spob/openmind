module ProjectsHelper
  def day_headings project
    (1..project.latest_iteration.daily_hour_totals.count).collect { |d| "<th>#{d}</th>" }.join
  end
end
