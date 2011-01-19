class ForumsController < ApplicationController
  before_filter :fetch_forum, :only => [:show]
  before_filter :login_required, :only => [:show], :if => :must_login
  before_filter :login_required, :except => [:index, :show, :rss, :search, :tag]
  access_control [:new, :destroy] => 'sysadmin',
                 [:edit, :create, :update] => 'sysadmin|mediator'
  helper :topics
  cache_sweeper :forums_sweeper, :only => [:create, :update, :destroy,
                                           :mark_all_as_read]

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create, :mark_all_as_read],
         :redirect_to => {:action => :index}
  verify :method => :put, :only => [:update],
         :redirect_to => {:action => :index}
  verify :method => :delete, :only => [:destroy],
         :redirect_to => {:action => :index}


  def new
    @forum = Forum.new
  end

  def show
    if @forum.tracked and @forum.can_edit?(current_user)
      if params[:form_based] == "yes"
        session[:topics_show_open] = (params[:show_open].nil? ? "no" : "yes")
        session[:topics_show_closed] = params[:show_closed].nil? ? "no" : "yes"
        session[:topics_owner_filter] = params[:owner_filter]
      else
        session[:topics_show_open] ||= "yes"
        session[:topics_show_closed] ||= "yes"
        session[:topics_owner_filter] ||= -1
        session[:topics_show_open] = params[:show_open] unless params[:show_open].nil?
        session[:topics_show_closed] = params[:show_closed] unless params[:show_closed].nil?
        session[:topics_owner_filter] = params[:owner_filter] unless params[:owner_filter].nil?
      end
      if session[:topics_owner_filter].to_i > 0
        session[:topics_owner_filter] = -1 unless @forum.mediators.collect(& :id).include? session[:topics_owner_filter].to_i
      end
    end
    @topics = Topic.list(params[:page],
                         current_user == :false ? 10 : current_user.row_limit,
                         @forum,
                         (@forum.mediators.include? current_user),
                         ((@forum.tracked and @forum.can_edit?(current_user)) ? session[:topics_show_open] == 'yes' : true),
                         ((@forum.tracked and @forum.can_edit?(current_user)) ? session[:topics_show_closed] == 'yes' : true),
                         ((@forum.tracked and @forum.can_edit?(current_user)) ? session[:topics_owner_filter].to_i : -1))
    unless @forum.can_see? current_user or prodmgr?
      flash[:error] = ForumsController.flash_for_forum_access_denied(current_user)
      redirect_to redirect_path_on_access_denied(current_user)
    end
  end

  def index
    unless read_fragment({:user_id => (logged_in? ? current_user.id : -1)})
      @forums = Forum.list_by_forum_group.find_all { |forum| forum.can_see? current_user }
      @forum_groups = ForumGroup.list_all current_user
    end
  end

  def self.week_size
    8
  end

  def metrics
    return unless has_metric_access?
    @weeks = []
    @weeks[1] = Date.today - Date.today.cwday.days
    @weeks[0] = @weeks[1] + 7.days
    (2..ForumsController.week_size + 1).each do |i|
      @weeks[i] = @weeks[i - 1] - 7.days
    end
    @forums = Forum.active.tracked.order_by_name.find_all { |f| f.can_edit? current_user }
  end

  def metrics_graphs
    return unless has_metric_access?
    @open_count_graph = open_flash_chart_object(800, 450, open_count_graphs_forums_path)
    @pending_count_graph = open_flash_chart_object(800,450, pending_count_graphs_forums_path)
    @days_pending_graph = open_flash_chart_object(800, 450, days_pending_graphs_forums_path)
    @oldest_days_pending_graph = open_flash_chart_object(800, 450, oldest_days_pending_graphs_forums_path)
  end

  def calc_metric_graph chart_title, y_legend
    colors = %w( #CF2626 #5767AF #336600 #356AA0 #CF5ACD #CF750C #D01FC3 #FF7200 #8F1A1A #ADD700 #57AF9D #C3CF5A #456F4F #C79810 )
    x = 0
    max = 0

    dot = SolidDot.new
    dot.size = x + 2
    dot.halo_size = 1
    dot.tooltip = "#date:d M y#<br>Value: #val#"
    chart = OpenFlashChart.new

    ForumMetric.all(:select => 'distinct enterprise_id').collect(& :enterprise).sort_by { |e| e.name }.each do |e|
      data = []
      e.forum_metrics.each do |m|
        data << ScatterValue.new(m.as_of.to_time.to_i, yield(m))
        #        data[90 - (Date.today.jd - m.as_of.jd)] = m.open_count
        max = yield(m) if yield(m) > max
      end
      #      90.times do |i|
      #        data[i] = 0 if data[i].nil?
      #      end
      line = ScatterLine.new(colors[x], 3)
      line.default_dot_style = dot
      #      line = Line.new
      line.text = e.name
      line.width = x + 2
      line.colour = colors[x]
      #      line.dot_size = 5
      line.values = data
      chart.add_element(line)
      x = x + 1
    end

    y = YAxis.new
    max = roundup(max, 5)
    y.set_range(0, max, calc_y_interval(max))
    #    y.set_range(0,15,5)
    chart.y_axis = y

    x = XAxis.new
    x.set_range(90.days.ago.to_i, Time.now.to_i)
    x.steps = 86400 * 7
    chart.x_axis = x

    labels = XAxisLabels.new
    labels.text = "#date: j M Y#"
    labels.steps = 86400 * 7
    labels.visible_steps = 1
    labels.rotate = 90
    x.labels = labels

    chart.set_title(Title.new(chart_title))

#    x_legend = XLegend.new("Date")
#    x_legend.set_style('{font-size: 20px; color: #778877}')
#    chart.set_x_legend(x_legend)

    y_legend = YLegend.new(y_legend)
    y_legend.set_style('{font-size: 20px; color: #770077}')
    chart.set_y_legend(y_legend)
    chart
  end

  def open_count_graphs
    render :text => calc_metric_graph("Open Forum Topics", "Topic Count") { |i| i.open_count }, :layout => false
  end

  def pending_count_graphs
    render :text => calc_metric_graph("Pending Forum Topics", "Topic Count"){|i| i.pending_count }, :layout => false
  end

  def days_pending_graphs
    render :text => calc_metric_graph("Average Days Pending Response", "Days"){|i| i.days_pending }, :layout => false
  end

  def oldest_days_pending_graphs
    render :text => calc_metric_graph("Oldest Days Pending Response", "Days"){|i| i.oldest_pending_days || 0.0 }, :layout => false
  end

  def create
    params[:forum][:mediator_ids] ||= []
    params[:forum][:group_ids] ||= []
    params[:forum][:enterprise_type_ids] ||= []
    @forum = Forum.new(params[:forum])
    if @forum.save
      flash[:notice] = "Forum #{@forum.name} was successfully created."
      redirect_to forums_path
    else
      render :action => :new
    end
  end

  def edit
    @forum = Forum.find(params[:id])
    unless @forum.can_edit? current_user
      flash[:error] = "You do not have access to edit that forum"
      redirect_to forums_path
    end
  end

  def update
    params[:forum][:mediator_ids] ||= []
    params[:forum][:group_ids] ||= []
    params[:forum][:enterprise_type_ids] ||= []
    @forum = Forum.find(params[:id])
    unless @forum.can_edit? current_user
      flash[:error] = "You do not have access to edit that forum"
      redirect_to forums_path
    end
    if @forum.update_attributes(params[:forum])
      flash[:notice] = "Forum '#{@forum.name}' was successfully updated."
      redirect_to forum_path(@forum)
    else
      render :action => :edit
    end
  end

  def mark_all_as_read
    @forum = Forum.find(params[:id])
    @forum.mark_all_topics_as_read current_user
    flash[:notice] = "All topics have been marked as read"
    redirect_to forum_path(@forum.id)
  end

  def search
    @hits = {}
    session[:forums_search] = params[:search]
    # solr barfs if search string starts with a wild card...so strip it out
    #    params[:search] = StringUtils.sanitize_search_terms params[:search]

    begin
      #      search_results = Topic.find_by_solr(params[:search], :scores => true)
      search_results = params[:search].blank? ? [] : Topic.search(params[:search], :retry_stale => true, :limit => 500)
    rescue RuntimeError => e
      flash[:error] = "An error occurred while executing your search. Perhaps there is a problem with the syntax of your search string."
      logger.error(e)
    else
      # not sure why this is necessary
      flash.discard

      if search_results.nil?
        redirect_to forums_path
        return
      end
      search_results.each do |topic|
        @hits[topic.id] = TopicHit.new(topic, true, 1) if topic.forum.can_see?(current_user) or prodmgr?
      end
      (params[:search].blank? ? [] : TopicComment.search(params[:search], :retry_stale => true, :limit => 500)).each do |comment|
        if (comment.topic.forum.can_see?(current_user) or prodmgr?) and
                (!comment.private or comment.topic.forum.mediators.include? current_user)
          # first see if topic hit already exists
          topic_hit = @hits[comment.topic.id]
          if topic_hit.nil?
            hit = TopicHit.new(comment.topic, false, 1)
            hit.comments << comment
            @hits[comment.topic.id] = hit
          else
            topic_hit.comments << comment
            topic_hit.score = comment.solr_score if topic_hit.score < 1
          end
        end
      end
    end
    TopicHit.normalize_scores(@hits.values)
  end

  def destroy
    forum = Forum.find(params[:id])
    name = forum.name
    forum.destroy
    flash[:notice] = "Forum #{name} was successfully deleted."
    redirect_to forums_url
  end

  def toggle_forum_details_box
    @forum = Forum.find(params[:id])
    if session[:forum_details_box_display] == "SHOW"
      session[:forum_details_box_display] = "HIDE"
    else
      session[:forum_details_box_display] = "SHOW"
    end

    respond_to do |format|
      format.html {
        index
      }
      format.js { do_rjs_toggle_forum_details_box }
    end
  end

  # Build an rss feed to be notified of new forum postings
  def rss
    forum = Forum.find(params[:id])
    comments = forum.comments_by_topic.find_all { |c| !c.private and forum.can_see? current_user }
    render_rss_feed_for comments, {
            :feed => {
                    :title => "New OpenMind Comments for Forum \"#{forum.name}\"",
                    :link => forum_url(forum.id),
                    :pub_date => :created_at
            },
            :item => {
                    :title => :rss_headline,
                    :description => :rss_body,
                    :link => Proc.new { |comment| "#{topic_url(comment.topic.id, :anchor => comment.id)}" }
            }
    }
  end

  def self.flash_for_forum_access_denied user
    return "You must be logged on to access this forum" if user == :false
    return "You have insuffient permissions to access this forum" unless user == :false
  end

  def tag
    @hits = {}
    @tags = params[:id]
    @forum = Forum.find(params[:forum]) unless params[:forum].nil?
    Topic.find_tagged_with(@tags).each do |topic|
      if (topic.forum.can_see?(current_user) or prodmgr?) and
              (@forum.nil? or @forum.id == topic.forum.id)
        @hits[topic.id] = TopicHit.new(topic, true, 100)
      end
    end
    render :action => :search
  end

  private

  def calc_y_interval x
    rounding_values = [1, 2, 5, 10, 15, 20, 25, 50, 75, 100, 150, 200, 250, 300, 400, 500, 750, 1000]
    x = x/8 + 1
    rounding_values.each do |v|
      return v if v > x
    end
    x
  end

  def roundup(num, into)
    return num if num % into == 0 # already a factor of into
    return num + into - (num % into) # go to nearest factor into
  end

  def redirect_path_on_access_denied user
    return forums_path unless user == :false
    return url_for(:controller => 'account', :action => 'login', :only_path => true) if user == :false
  end

  def do_rjs_toggle_forum_details_box
    render :update do |page|
      page.replace "forum_details_area",
                   :partial => "show_hide_forum_details"
      if session[:forum_details_box_display] == "HIDE"
        page.visual_effect :blind_up, :forum_details, :duration => 0.5
      else
        page.visual_effect :blind_down, :forum_details, :duration => 1
      end
    end
  end

  def fetch_forum
    @forum = Forum.find(params[:id])
  end

  def must_login
    (!@forum.public? and current_user == :false)
  end

  def has_metric_access?
    if !logged_in?
      flash[:error] = "You must login to access that page"
      redirect_to forums_path
      return false
    elsif current_user.can_view_metrics?
      return true
    else
      flash[:error] = "You don't have access to view that page"
      redirect_to forums_path
      return false
    end
  end
end
