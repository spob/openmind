class ReleasesController < ApplicationController
  before_filter :login_required, :except => [:index, :list, :show, :check_for_updates]
  access_control [:new, :commit, :index, :edit, :create, :update, :destroy] => 'prodmgr'
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create, :commit ],
  :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
  :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
  :redirect_to => { :action => :index }
  
  def index
    begin
      id = params[:product_id]
      @product = Product.find(id)
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid product #{params[:product_id]}")
      flash[:notice] = "Attempted to view releases for an invalid product"
      redirect_to products_path
      return false
    else
      @releases = Release.list params[:page], @product.id, 
       (logged_in? ? current_user.row_limit : 10)
      @release_statuses = ReleaseStatus.find(:all, :order => "sort_value ASC")
      return true
    end
  end
  
  def list    
    @release_statuses ||= ReleaseStatus.find(:all, :order => "sort_value ASC")
    session[:release_status_id] = params[:release_status_id] unless params[:release_status_id].nil?
    session[:release_status_id] ||= @release_statuses[0].id
    @releases = Release.list_by_status params[:page], 
     (logged_in? ? current_user.row_limit : 10),
    session[:release_status_id]
  end
  
  def show
    id = params[:id]
    @release = Release.find(id)
  end
  
  def new
    begin
      @product = Product.find(params[:product_id])
      @release_statuses = ReleaseStatus.find(:all, :order => "sort_value ASC")
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid product #{params[:id]}")
      flash[:notice] = "Attempted to create a release for an invalid product"
      redirect_to products_path
    else
      @release = Release.new
    end
  end
  
  def create
    Release.transaction do
      Release.transaction do
        product_id = params[:product_id]
        @release = Release.new(params[:release])
        @release.product_id = product_id
        @release.change_logs <<  ReleaseChangeLog.new(:message => "Release created",
        :user => current_user)
        
        if @release.save
          run_change_log_job @release.id
          flash[:notice] = "Release #{@release.version} was successfully created."
          redirect_to releases_path(:product_id => product_id)
        else
          @product = Product.find(product_id)
          render :action => 'new', :product_id => product_id if index
        end
      end
    end
  end
  
  def preview
    render :layout => false
  end
  
  def edit
    @release_statuses ||= ReleaseStatus.find(:all, :order => "sort_value ASC")
    @release ||= Release.find(params[:id])
  end
  
  def  check_for_updates
    release_ids = {}
    @serial_number = params[:serial_number]
    params[:releases].split(",").collect { |x| release_ids[x.split("|")[0]] = x.split("|")[1] } unless params[:releases].nil? or params[:releases].blank?
    
    @releases = []
    @expired_maintenance = false
    release_ids.keys.each do |id|
      release = Release.find_by_id(id)
      release = Release.find_by_external_release_id(id) unless release
      if release.nil?
        flash[:error] = "Couldn't find product with id '#{id}'" 
      else
        if release_ids[id] 
          begin
            release.maintenance_expires = Date.parse(release_ids[id]) 
            
            @expired_maintenance = true if release.maintenance_expires < Date.today
          rescue ArgumentError
            flash[:error] = "Invalid date format '#{release_ids[id]}'" 
          end
        end
        
        @releases << release 
      end
    end
    @latest_release = {}
    @unsatisfied_dependencies = {}
    @releases.each do |release|
      @latest_release[release], @unsatisfied_dependencies[release] = release.update_available(@releases)
    end
    new_releases = @latest_release.values.delete_if {|x| x.nil?}
    xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><releases type=\"array\"></releases>"
    xml = new_releases.to_xml unless new_releases.empty?
    respond_to do |wants|
      wants.html
      wants.xml { render :xml => xml }
    end   
  end
  
  #
  # I needed to create a special method called commit that was a post because,
  # for some reason, the update (which is a put) wouldn't work with the preview
  # textile stuff
  def commit
    update
  end
  
  def update
    @release = Release.find(params[:id])
    Release.transaction do
      @release.release_dependencies.clear
      if params[:release][:release_dependencies]
        for release_id in params[:release][:release_dependencies]
          depends_upon = Release.find(release_id.to_i)
          @release.release_dependencies.create!(:depends_on => depends_upon)
        end
      end
      @release.description = params[:release][:description]
      @release.user_release_date = params[:release][:user_release_date]
      @release.release_status_id = params[:release][:release_status_id]
      @release.version = params[:release][:version]
      @release.download_url = params[:release][:download_url]
      @release.external_release_id = params[:release][:external_release_id]
      @release.release_date = params[:release][:release_date]
      calc_change_history @release
      run_change_log_job @release.id
      
      if @release.save
        flash[:notice] = "Release #{@release.version} was successfully updated."
        redirect_to release_path(@release)
      else
        edit
        render :action => 'edit'
      end
    end
  end
  
  def destroy
    release = Release.find(params[:id])
    product = release.product
    version = release.version
    release.destroy
    flash[:notice] = "Release #{version} for product #{product.name} was successfully deleted."
    redirect_to releases_path(:product_id => product.id)
  end
  
  private
  
  def run_change_log_job release_id
    # run job in the feature to notify of changes (in case user makes several
    # changes, we will only ping watchers once
    RunOncePeriodicJob.create(
                              :job => "Release.send_change_notifications(#{release_id})",
    :next_run_at => Time.zone.now + 10.minutes)
  end
  
  def calc_change_history release    
    add_change_history_from_message release, "Description updated" if release.description_changed?
    add_change_history_old_new release, "Release Date",
    @release.user_release_date_was,
    @release.user_release_date if release.user_release_date_changed?
    add_change_history_old_new release, "Release Status",
    ReleaseStatus.find(@release.release_status_id_was).short_name,
    @release.release_status.short_name if release.release_status_id_changed?
    add_change_history_from_changes release, "Version Name",
    release.changes['version'] if release.version_changed?
    add_change_history_from_changes release, "Download URL",
    release.changes['download_url'] if release.download_url_changed?
  end
  
  def add_change_history_old_new release, label, old_value, new_value
    if old_value.nil? or old_value.blank?
      add_change_history_from_message release, "#{label} set to \"#{new_value}\""
    elsif new_value.nil? or new_value.blank?
      add_change_history_from_message release, "#{label} changed from \"#{old_value}\" to null"
    else
      add_change_history_from_message release, "#{label} changed from \"#{old_value}\" to \"#{new_value}\""
    end
  end
  
  def add_change_history_from_changes release, label, old_and_new_values
    add_change_history_old_new release, label, old_and_new_values[0], old_and_new_values[1]
  end
  
  def add_change_history_from_message release, message
    release.change_logs <<  ReleaseChangeLog.new(:message => message,
                                                 :user => current_user)
  end
end