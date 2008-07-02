class PollsController < ApplicationController
  before_filter :login_required
  access_control [:new, :commit, :edit, :create, :update, :destroy,
    :publish, :unpublish ] => 'prodmgr'
  
  def index
    new
    @polls = Poll.list params[:page], current_user.row_limit
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create, :publish, :unpublish, :take_survey ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }

  def show
    @poll = Poll.find(params[:id])
  end

  def new
    @poll = Poll.new
    @poll.close_date = Date.jd(Date.today.jd + 7)
  end

  def create
    @poll = Poll.new(params[:poll])
    @poll.poll_options << PollOption.new(:description => 'Choice 1...')
    @poll.poll_options << PollOption.new(:description => 'Choice 2...')
    if @poll.save
      flash[:notice] = "Poll #{@poll.title} was successfully created."
      redirect_to edit_poll_path(@poll)
    else
      index
      render :action => :index
    end
  end

  def edit
    @poll = Poll.find(params[:id])
  end

  def update
    @poll = Poll.find(params[:id])
    if @poll.update_attributes(params[:poll])
      flash[:notice] = "Poll '#{@poll.title}' was successfully updated."
      redirect_to poll_path(@poll)
    else
      render :action => :edit
    end
  end

  def destroy
    poll = Poll.find(params[:id])
    title = poll.title
    poll.destroy
    flash[:notice] = "Poll #{title} was successfully deleted."
    redirect_to polls_url
  end
  
  def publish
    poll = set_active params[:id], true
    flash[:notice] = "Poll #{poll.title} was successfully published."
    redirect_to polls_url
  end
  
  def unpublish
    poll = set_active params[:id], false
    flash[:notice] = "Poll #{poll.title} was successfully unpublished."
    redirect_to polls_url
  end
  
  def take_survey
    if params[:poll_option_id].nil?
      take_survey_failed "You must select an option"
    else
      poll_option = PollOption.find(params[:poll_option_id])
      if poll_option.poll.taken_survey?(current_user)
        take_survey_failed "You can only answer this survey once"
      else
        poll_option.user_responses << current_user
        poll_option.save
        redirect_to poll_path(poll_option.poll)
      end
    end
  end
  
  def present_survey
    @poll = Poll.find(params[:id])
    if @poll.taken_survey?(current_user)
      flash[:error] = "You can only answer this survey once"
      redirect_to poll_path(@poll)
    end
  end
  
  private
  
  def take_survey_failed(msg)
    @poll = Poll.find(params[:id])
    flash[:error] = msg
    render :action => :present_survey
  end
  
  def set_active(id, active)
    @poll = Poll.find(id)
    @poll.active = active
    @poll.save
    @poll
  end
end