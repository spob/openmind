class EnterprisesController < ApplicationController
  before_filter :login_required
  access_control :DEFAULT => 'sysadmin | allocmgr'
  
  verify :method => :post, :only => [:create ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }
  
  def index
    @enterprise ||= Enterprise.new(:initial_allocation => 0)
    session[:enterprise_start_filter] = params[:start_filter] unless params[:start_filter].nil?
    session[:enterprise_end_filter] = params[:end_filter] unless params[:end_filter].nil?
    session[:enterprise_start_filter] = "All" if session[:enterprise_start_filter].nil?
    session[:enterprise_end_filter] = "All" if session[:enterprise_end_filter].nil?
    unless session[:enterprise_start_filter].nil?
      session[:enterprises_search] = nil
    end
    @enterprises = Enterprise.list params[:page], current_user.row_limit, 
      session[:enterprise_start_filter], session[:enterprise_end_filter], nil
    set_start_end_tags
  end

  def search
    session[:enterprise_start_filter] = "All"
    session[:enterprise_end_filter] = "All"
    session[:enterprises_search] = params[:search]

#    params[:search] = StringUtils.sanitize_search_terms params[:search]
    set_start_end_tags
    begin
#      search_results = Enterprise.find_by_solr(params[:search], :lazy => true).docs.collect(&:id)
      search_results = Enterprise.search_for_ids(params[:search])
    rescue RuntimeError => e
      flash[:error] = "An error occurred while executing your search. Perhaps there is a problem with the syntax of your search string."
      logger.error(e)
      redirect_to enterprises_path
    else
      @enterprises = Enterprise.list params[:page], 999,
        session[:enterprise_start_filter],
        session[:enterprise_end_filter],
        search_results
      render :action => 'index'
    end      
  end

  def show
    @enterprise = Enterprise.find(params[:id])
  end

  def next
    enterprise = Enterprise.find(params[:id])
    enterprises = Enterprise.next(enterprise.name)
    if enterprises.empty?
      @enterprise = enterprise
    else
      @enterprise = enterprises.first
    end
    render :action => 'show'
  end

  def previous
    enterprise = Enterprise.find(params[:id])
    enterprises = Enterprise.previous(enterprise.name)
    if enterprises.empty?
      @enterprise = enterprise
    else
      @enterprise = enterprises.first
    end
    render :action => 'show'
  end
  
  def create
    @enterprise = Enterprise.new(params[:enterprise])
    parse_error = nil
    if allocmgr? and !@enterprise.initial_allocation.nil? and @enterprise.initial_allocation.length > 0
      qty = Integer(@enterprise.initial_allocation) rescue parse_error = "Available votes must be an integer value"
      parse_error = "Available votes cannot be less than zero" if parse_error.nil? and qty < 0
      if !parse_error.nil?
        flash[:error] = parse_error
        index
        render :action => 'index'
        return
      elsif qty > 0
        alloc = EnterpriseAllocation.new(
          :quantity => qty, 
          :comments => "",
          :expiration_date => Allocation.calculate_expiration_date)
      end
    end
    if @enterprise.save
      unless alloc.nil?
        alloc.enterprise = @enterprise
        alloc.save
      end
      flash[:notice] = "Enterprise #{@enterprise.name} was successfully created."
      redirect_to enterprises_path
    else
      index
      render :action => 'index'
    end  
  end
  
  def edit
    @enterprise  = Enterprise.find(params[:id])
  end  

  def update
    @enterprise = Enterprise.find(params[:id])
    if @enterprise.update_attributes(params[:enterprise])
      flash[:notice] = "Enterprise #{@enterprise.name} was successfully updated."
      redirect_to enterprise_path(@enterprise)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    enterprise = Enterprise.find(params[:id])
    name = enterprise.name
    enterprise.destroy
    flash[:notice] = "Enterprise #{name} was successfully deleted."
    redirect_to enterprises_path
  end  

  private
  
  def set_start_end_tags
    count = Enterprise.count
    if count > 50
      @tag1_begin = Enterprise.find(:first, :select => "name", :order => "name").name
      @tag1_end = Enterprise.find(:first, :select => "name", :offset => count/5, :order => "name").name
      @tag2_begin = Enterprise.find(:first, :select => "name", :offset => count/5 + 1, :order => "name").name
      @tag2_end = Enterprise.find(:first, :select => "name", :offset => 2*count/5, :order => "name").name
      @tag3_begin = Enterprise.find(:first, :select => "name", :offset => 2*count/5 + 1, :order => "name").name
      @tag3_end = Enterprise.find(:first, :select => "name", :offset => 3*count/5, :order => "name").name
      @tag4_begin = Enterprise.find(:first, :select => "name", :offset => 3*count/5 + 1, :order => "name").name
      @tag4_end = Enterprise.find(:first, :select => "name", :offset => 4*count/5, :order => "name").name
      @tag5_begin = Enterprise.find(:first, :select => "name", :offset => 4*count/5 + 1, :order => "name").name
      @tag5_end = Enterprise.find(:first, :select => "name", :offset => count-1, :order => "name").name
    end
  end
end
