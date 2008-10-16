class AnnouncementsController < ApplicationController
  before_filter :login_required, :except => [:rss]
  access_control [:edit, :update, :destroy, :new, :create] => 'prodmgr | sysadmin'
  

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create, :export, :import ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }
  
  def index
    current_user.update_attribute(:last_message_read, Time.zone.now)
    @announcements = Announcement.list params[:page], current_user.row_limit
  end

  def show
    @announcement = Announcement.find(params[:id])
  end

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = Announcement.new(params[:announcement])
    if @announcement.save
      flash[:notice] = 'Announcement was successfully created.'
      redirect_to announcements_path
    else
      render :action => 'new'
    end
  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

  def update
    @announcement = Announcement.find(params[:id])
    if @announcement.update_attributes(params[:announcement])
      flash[:notice] = 'Announcement was successfully updated.'
      redirect_to announcements_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    Announcement.find(params[:id]).destroy
    flash[:notice] = "Announcement was successfully deleted."
    redirect_to announcements_path
  end

  def preview
    render :layout => false
  end

  # Build an rss feed to be notified of new announcements
  def rss
    render_rss_feed_for Announcement.find(:all, :order => 'created_at DESC',
      :limit => 10), {
      :feed => {
        :title => 'OpenMind New Announcements',
        :link => announcements_url,
        :pub_date => :created_at
      },
      :item => {
        :title => :headline,
        :description => :formatted_description,
        :link => Proc.new{|announcement| "#{announcements_url}##{announcement.id}" }
      }
    }
  end
end
