class ReleasesController < ApplicationController
  before_filter :login_required
  access_control [:new, :commit, :index, :edit, :create, :update, :destroy] => 'prodmgr'
  
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
      @releases = Release.list params[:page], @product.id, current_user.row_limit
      @release_statuses = ReleaseStatus.find(:all, :order => "sort_value ASC")
      return true
    end
  end
  
  def list    
    @release_statuses ||= ReleaseStatus.find(:all, :order => "sort_value ASC")
    session[:release_status_id] = params[:release_status_id] unless params[:release_status_id].nil?
    session[:release_status_id] ||= @release_statuses[0].id
    @releases = Release.list_by_status session[:release_status_id]
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create, :commit ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }

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
    product_id = params[:product_id]
    @release = Release.new(params[:release])
    @release.product_id = product_id
    if @release.save
      flash[:notice] = "Release #{@release.version} was successfully created."
      redirect_to releases_path(:product_id => product_id)
    else
      @product = Product.find(product_id)
      render :action => 'new', :product_id => product_id if index
    end
  end

  def preview
    render :layout => false
  end

  def edit
    @release_statuses ||= ReleaseStatus.find(:all, :order => "sort_value ASC")
    @release ||= Release.find(params[:id])
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
    if @release.update_attributes(params[:release])
      flash[:notice] = "Release #{@release.version} was successfully updated."
      redirect_to releases_path(:product_id => @release.product.id)
    else
      edit
      render :action => 'edit'
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
end
