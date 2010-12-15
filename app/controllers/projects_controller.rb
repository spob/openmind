class ProjectsController < ApplicationController
  before_filter :login_required
  before_filter :fetch_project, :only => [:destroy, :edit, :update]

  verify :method      => :post, :only => [:create, :refresh],
         :redirect_to => {:action => :index}
  verify :method      => :put, :only => [:update],
         :redirect_to => {:action => :index}
  verify :method      => :delete, :only => [:destroy],
         :redirect_to => {:action => :index}

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
    if params[:iteration_id]
      @iteration = Iteration.find(params[:iteration_id], :include => [{:stories => {:tasks => :task_estimates}}])
    else
      @iteration = @project.latest_iteration
    end
    @burndown_chart = open_flash_chart_object(800, 450, burndown_chart_project_path(@iteration))
  end

  def refresh
    @project = Project.find(params[:id], :include => [{:latest_iteration => {:stories => {:tasks => :task_estimates}}}])
    @project.refresh
    if @project.save
      flash[:notice] = "Project #{@project.name} was successfully refreshed."
    else
      flash[:error] = "Project #{@project.name} refresh failed."
    end
    redirect_to projects_path
  end

  def chart_line(data, label, color)
    dot                    = SolidDot.new
    dot.size               = 2
    dot.halo_size          = 1
    dot.tooltip            = "#date:d M y#<br>Value: #val#"

    line                   = ScatterLine.new(color, 3)
    line.default_dot_style = dot
    line.text              = label
    line.width             = 2
    line.colour            = color
    line.values            = data
    line
  end

  def burndown_chart
    iteration            = Iteration.find(params[:id])
    colors               = %w( #CF2626 #5767AF #336600 #356AA0 #CF5ACD #CF750C #D01FC3 #FF7200 #8F1A1A #ADD700 #57AF9D #C3CF5A #456F4F #C79810 )
    hours_max            = 0.0

    chart                = OpenFlashChart.new

    remaining_hours_data = []
    total_hours_data     = []
    ideal_hours_data     = []
    daily_progress = iteration.latest_estimate.total_hours/(iteration.project.iteration_length * 5)
    iteration.task_estimates.each do |e|
      remaining_hours_data << ScatterValue.new(e.as_of.to_time.to_i, e.remaining_hours)
      total_hours_data << ScatterValue.new(e.as_of.to_time.to_i, e.total_hours)
      ideal_hours_data << ScatterValue.new(e.as_of.to_time.to_i, iteration.latest_estimate.total_hours - (daily_progress * iteration.calc_day_number(e.as_of)))
      hours_max = max(hours_max, e.remaining_hours, e.total_hours)
    end
    chart.add_element(chart_line(remaining_hours_data, "Remaining Hours", colors[0]))
    chart.add_element(chart_line(total_hours_data, "Total Hours", colors[1]))
    chart.add_element(chart_line(ideal_hours_data, "Ideal Hours", colors[2]))

    y          = YAxis.new
    hours_max  = roundup(hours_max, 5)
    y_interval = calc_y_interval(hours_max)
    hours_max = ((hours_max/y_interval).to_i + 1) * y_interval if hours_max/y_interval != (hours_max/y_interval).to_i
    y.set_range(0, hours_max, y_interval)
    #    y.set_range(0,15,5)
    chart.y_axis = y

    x            = XAxis.new
    x.set_range(iteration.task_estimates.first.as_of.to_time.to_i, iteration.task_estimates.last.as_of.to_time.to_i)
    x.steps              = 86400
    chart.x_axis         = x

    labels               = XAxisLabels.new
    labels.text          = "#date: j M Y#"
    labels.steps         = 86400
    labels.visible_steps = 1
    labels.rotate        = 90
    x.labels             = labels
    title                = Title.new(iteration.iteration_name)
    chart.set_title(title)

#    x_legend = XLegend.new("Date")
#    x_legend.set_style('{font-size: 20px; color: #778877}')
#    chart.set_x_legend(x_legend)

    y_legend = YLegend.new("Points")
    y_legend.set_style('{font-size: 20px; color: #770077}')
    chart.set_y_legend(y_legend)
    render :text => chart, :layout => false
  end

  private

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
        a.each {|x| maximum = x if maximum.nil? || x > maximum }
      else
        maximum = a if maximum.nil? || a > maximum
      end
    end
    maximum
  end
end
