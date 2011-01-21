class ProjectsController < ApplicationController
  COLORS = %w( #CF2626 #5767AF #336600 #356AA0 #CF5ACD #CF750C #D01FC3 #FF7200 #8F1A1A #ADD700 #57AF9D #C3CF5A #456F4F #C79810 )
  before_filter :login_required
  before_filter :fetch_project, :only => [:destroy, :edit, :update, :show, :show_chart]

  verify :method      => :post, :only => [:create, :refresh],
         :redirect_to => {:action => :index}
  verify :method      => :put, :only => [:update],
         :redirect_to => {:action => :index}
  verify :method      => :delete, :only => [:destroy],
         :redirect_to => {:action => :index}

  access_control [:burndown_chart, :destroy, :show, :velocity_chart] => 'developer'

  layout :layout_for_action

  def index
    if can_view_projects?
      @projects = Project.list params[:page], current_user.row_limit
    end
  end


  def create
    if can_edit_projects?
      @project = Project.new(params[:project])
      if @project.save
        flash[:notice] = "Project was successfully created."
        redirect_to projects_path
      else
        index
        render :action => 'index'
      end
    end
  end

  def edit
    can_edit_projects?
  end

  def update
    if can_edit_projects?
      if @project.update_attributes(params[:project])
        flash[:notice] = "Project #{@project.name} was successfully updated."
        redirect_to projects_path
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    name = @project.name || ""
    @project.destroy
    flash[:notice] = "Project #{name} was successfully deleted."
    redirect_to projects_path
  end

  def show
    @project = Project.find(params[:id])
    cookies[:show_pushed_stories] = { :value => params[:show_pushed_stories], :expires => 6.month.since } if params[:show_pushed_stories]
    cookies[:show_accepted_stories] = { :value => params[:show_accepted_stories], :expires => 6.month.since } if params[:show_accepted_stories]

    if params[:iteration_id]
      @iteration = Iteration.find(params[:iteration_id], :include => [{:stories => {:tasks => :task_estimates}}])
    else
      @iteration = @project.latest_iteration
    end
    @burndown_chart = open_flash_chart_object(1024, 450, burndown_chart_project_path(@iteration))
#    @velocity_chart = open_flash_chart_object(1024, 450, velocity_chart_project_path(@iteration))
  end

  def show_chart
    show
  end

  def refresh
    @project = Project.find(params[:id], :include => [{:latest_iteration => {:stories => {:tasks => :task_estimates}}}])
    @project.refresh
    if @project.save
      flash[:notice] = "Project #{@project.name} was successfully refreshed."
    else
      flash[:error] = "Project #{@project.name} refresh failed."
    end
    redirect_to (params[:from] == "show" ? project_path(@project) : projects_path)
  end

  def velocity_chart
    iteration = Iteration.find(params[:id])

    title     = Title.new("Daily Velocity for #{iteration.iteration_name}")
    velocity_data, delivered_data = calc_velocity_chart_data(iteration)

    chart       = OpenFlashChart.new
    chart.title = title
    set_legend(chart, "Day #", "Story Points")
    chart.y_axis = generate_y_axis(max(velocity_data, delivered_data))
    chart.add_element(chart_bar(velocity_data, "Velocity", COLORS[1]))
    chart.add_element(chart_bar(delivered_data, "Points Delivered", COLORS[2]))
    chart.set_tooltip(create_tooltip())

    render :text => chart.to_s
  end

  def burndown_chart
    iteration = Iteration.find(params[:id])

    ideal_hours_data, remaining_hours_data, total_hours_data = calc_hour_chart_data(iteration)
    velocity_data, delivered_data = calc_velocity_chart_data(iteration)

    title = Title.new("Burn Down for #{iteration.iteration_name}")
    title.set_style('{font-size: 20px; color: #770077}')


    chart =OpenFlashChart.new
    chart.set_title(title)
    chart.y_axis       = generate_y_axis(max(ideal_hours_data, remaining_hours_data, total_hours_data))
    chart.y_axis_right = generate_y_axis(max(velocity_data, delivered_data), true)
    set_legend(chart, "Day #", "Task Hours", "Story Points")

    chart.add_element(chart_line(remaining_hours_data, "Remaining Hours", COLORS[0]))
    chart.add_element(chart_line(total_hours_data, "Total Hours", COLORS[1]))
    chart.add_element(chart_line(ideal_hours_data, "Ideal Hours", COLORS[2]))
    chart.add_element(chart_bar(velocity_data, "Velocity", COLORS[4]))
    chart.add_element(chart_bar(delivered_data, "Points Delivered", COLORS[5]))
    chart.set_tooltip(create_tooltip())

    render :text => chart.to_s
  end

  private

  def create_tooltip
    t = Tooltip.new
    t.set_shadow(false)
    t.stroke = 5
    t.colour = '#6E604F'
    t.set_background_colour("#BDB396")
    t.set_title_style("{font-size: 14px; color: #CC2A43;}")
    t.set_body_style("{font-size: 10px; font-weight: bold; color: #000000;}")
    t
  end

  def chart_line(data, label, color)
    dot                    = HollowDot.new
    dot.size               = 3
    dot.halo_size          = 2
    dot.tooltip            = "#{label}<br>val = #val#"

    line                   = Line.new
    line.text              = label
    line.width             = 2
    line.colour            = color
    line.default_dot_style = dot
    line.dot_size          = 5
    line.values            = data
    line
  end

  def chart_bar(data, label, color)
    bar         = Bar.new
    bar.text    = label
    bar.values  = data
    bar.tooltip = "#{label}<br>val = #val#"
    bar.colour  = color
    bar.attach_to_right_y_axis
    bar
  end

  def calc_velocity_chart_data(iteration)
    velocity_data  = []
    delivered_data = []

    iteration.task_estimates.each do |e|
      day_number                 = iteration.calc_day_number(e.as_of)
      velocity_data[day_number]  = e.velocity
      delivered_data[day_number] = e.points_delivered
    end
    return velocity_data, delivered_data
  end

  def generate_y_axis(max, right=false)
    y          = (right ? YAxisRight.new : YAxis.new)
    hours_max  = roundup(max, 5)
    y_interval = calc_y_interval(hours_max)
    hours_max = ((hours_max/y_interval).to_i + 1) * y_interval if hours_max/y_interval != (hours_max/y_interval).to_i
    y.set_range(0, hours_max, y_interval)
    y
  end

  def calc_hour_chart_data(iteration)
    remaining_hours_data    = []
    total_hours_data        = []
    ideal_hours_data        = []
    daily_progress          = iteration.latest_estimate.total_hours/(iteration.project.iteration_length * 5)

    remaining_hours_data[0] = iteration.task_estimates.first.total_hours
    total_hours_data[0]     = iteration.task_estimates.first.total_hours
    ideal_hours_data[0]     = iteration.latest_estimate.total_hours

    iteration.task_estimates.each do |e|
      day_number                       = iteration.calc_day_number(e.as_of)
      remaining_hours_data[day_number] = e.remaining_hours
      total_hours_data[day_number]     = e.total_hours
      ideal_hours_data[day_number]     = iteration.latest_estimate.total_hours - (daily_progress * day_number)
    end
    return ideal_hours_data, remaining_hours_data, total_hours_data
  end

  def set_legend(chart, x_legend, y_legend, y_legend_right=nil)
    x_legend = XLegend.new(x_legend)
    x_legend.set_style('{font-size: 20px; color: #778877}')

    y_legend = YLegend.new(y_legend)
    y_legend.set_style('{font-size: 20px; color: #770077}')

    chart.set_x_legend(x_legend)
    chart.set_y_legend(y_legend)

#    if y_legend_right
#      y_legend_right = YLegendRight.new("My Legend")
#      y_legend_right.set_style('{font-size: 20px; color: #770077}')
#      chart.y_legend = y_legend_right
#    end
  end

  def can_view_projects?
    return true if current_user.developer?
    flash[:error] = "You do not have access to that page"
    redirect_to home_path
    false
  end

  def can_edit_projects?
    return true if current_user.developer? && current_user.sysadmin?
    flash[:error] = "You do not have access to edit a project"
    redirect_to projects_path
    false
  end

  def fetch_project
    @project = Project.find(params[:id])
  end

  def calc_y_interval x
    rounding_values = [1, 2, 5, 10, 15, 20, 25, 50, 75, 100, 150, 200, 250, 300, 400, 500, 750, 1000]
    x               = x/8 + 1
    rounding_values.each do |v|
      return v if v > x
    end
    x
  end

  def roundup(num, into)
    return num if num % into == 0 # already a factor of into
    return num + into - (num % into) # go to nearest factor into
  end

  def max(*args)
    maximum = nil
    args.each do |a|
      if a.kind_of? Array
        a.each { |x| maximum = x if !x.nil? && (maximum.nil? || x > maximum) }
      else
        maximum = a if maximum.nil? || a > maximum
      end
    end
    maximum
  end

  def layout_for_action
    if %w(show_chart).include?(params[:action])
      'printer'
    else
      'application'
    end
  end
end
