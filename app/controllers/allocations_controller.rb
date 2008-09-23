require 'fastercsv'
require 'csv'

class AllocationsController < ApplicationController
  before_filter :login_required
  access_control [:create, :new, :export, :import, :update, :destroy, :export_import, :edit] => 'allocmgr'
  helper_method :toggle_image_button
  
  @@types = [
    ["User Allocation",  "UserAllocation"],
    ["Enterprise Allocation",  "EnterpriseAllocation"]
  ]
  
  def self.types
    @@types
  end

  def index
    if params[:form_based] == "yes"
      session[:active_allocations_only] = (params[:active_only].nil? ? "no" : "yes")
      session[:allocations_filter_user] = params[:allocations_filter_user].nil? ? "no" : "yes"
      session[:allocations_filter_enterprise] = params[:allocations_filter_enterprise].nil? ? "no" : "yes"
    else
      session[:active_allocations_only] ||= "yes"
      session[:active_allocations_only] = params[:active_only] unless params[:active_only].nil?
      session[:allocations_filter_user] ||= "yes" unless allocmgr?
      session[:allocations_filter_user] = params[:allocations_filter_user] unless params[:allocations_filter_user].nil?
      session[:allocations_filter_enterprise] ||= "yes" unless allocmgr?
      session[:allocations_filter_enterprise] = params[:allocations_filter_enterprise] unless params[:allocations_filter_enterprise].nil?
    end
    
    @allocations = Allocation.list( 
      (session[:allocations_filter_user] == "yes" ? current_user : nil),
      (session[:allocations_filter_enterprise] == "yes" ? current_user.enterprise : nil),
      !allocmgr?,
      params[:page], current_user.row_limit,
      (session[:active_allocations_only] == 'yes'))
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create, :export, :import ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }
 
  def show
    @allocation = Allocation.find(params[:id])
  end

  def new
    if @allocation.nil?
      @allocation = UserAllocation.new
      @allocation.expiration_date = Allocation.calculate_expiration_date
    end
  end

  def create
    params[:allocation][:user_id] = nil unless params[:allocation][:allocation_type] == "UserAllocation"
    params[:allocation][:enterprise_id] = nil unless params[:allocation][:allocation_type] == "EnterpriseAllocation"
    command = "#{params[:allocation][:allocation_type]}.new(params[:allocation])"
    @allocation = eval command
    if @allocation.save
      flash[:notice] = "#{@allocation.class} allocation was successfully created."
      redirect_to allocations_path
    else
      new
      render :action => 'new'
    end
  end

  def edit
    @allocation = Allocation.find(params[:id])
  end

  def update
    @allocation = Allocation.find(params[:id])
    if @allocation.update_attributes(params[:allocation])
      flash[:notice] = 'Allocation was successfully updated.'
      redirect_to allocations_path # allocation_path(@allocation)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Allocation.find(params[:id]).destroy
    flash[:notice] = "Allocation was successfully deleted."
    redirect_to allocations_path
  end
  
  def export_import
    session[:allocation_load_toggle_pix] ||= "HIDE"
    @errors = []
    @allocations = []
  end
  
  # Generate a csv file of users and enterprises
  def export
    users = User.active_voters
    enterprises = Enterprise.find(:all, :order => "name ASC")
    stream_csv do |csv|
      cols = ["type", "email","name","enterprise","user groups", "allocation qty","expire days","comments"]
      cols << CustomField.users_custom_boolean1 unless CustomField.users_custom_boolean1.nil?
      csv << cols
      enterprises.each do |e|
        cols = ["Enterprise", "","",e.name,"",0,APP_CONFIG['allocation_expiration_days'],""]
        cols << "" unless CustomField.users_custom_boolean1.nil?
        csv << cols
      end
      users.each do |u|
        cols =  ["User", u.email,u.full_name,u.enterprise.name,array_to_string(u.groups.collect(&:name)), 0,APP_CONFIG['allocation_expiration_days'],""]
        cols << u.custom_boolean1 unless CustomField.users_custom_boolean1.nil?
        csv << cols
      end
    end
  end
  
  def import 
    @parsed_file=CSV::Reader.parse(params[:dump][:file])
    @errors = []
    @allocations = []
    base_comments = "Allocation imported by #{current_user.email}"
    n = -1
    @parsed_file.each do |row|
      if n == -1
        # skip the first line -- it's the header
        n = 0
        next
      end
      n += 1
      type = row[0]
      begin
        qty = Integer(row[5])
      rescue ArgumentError
        @errors << "Record #{n}: '#{row[4]}' is an invalid value for allocation qty. Must be an integer"
        next
      end
      if qty < 0
        @errors << "Record #{n}: invalid qty '#{qty}', must be greater than or equal to 0"
        next
      end
      
      if (row[7].nil? || row[7].empty?)
        comments = base_comments
      else
        comments = "#{row[7]} (#{base_comments})" 
      end
      next if qty == 0
      
      begin
        expire_days = Integer(row[6])
      rescue ArgumentError
        @errors << "Record #{n}: '#{row[6]}' is an invalid value for expire days. Must be an integer"
        next
      end
      if expire_days <= 0
        @errors << "Record #{n}: invalid expire days '#{expire_days}', must be greater than 0"
        next
      end
      expiration_date = 
        Date.jd(DateUtils.today.jd + expire_days)
      
      if type == "User"
        user = User.find_by_email(row[1])
        if user.nil?
          @errors << "Record #{n}: no such user: '#{row[1]}'"
          next
        end
        @allocations << UserAllocation.new(:quantity => qty, :user_id => user.id,
          :comments => comments, :expiration_date => expiration_date)
      elsif type == "Enterprise"
        enterprise = Enterprise.find_by_name(row[3])
        if enterprise.nil?
          @errors << "Record #{n}: no such enterprise: '#{row[3]}'"
          next
        end
        @allocations << EnterpriseAllocation.new(:quantity => qty, 
          :enterprise_id => enterprise.id,
          :comments => comments, 
          :expiration_date => expiration_date)
      else
        @errors << "Record #{n}: invalid type: '#{type}'"
      end
    end
    fail = false
    if @errors.empty?
      n = 0
      for allocation in @allocations
        if allocation.save
          n += 1 
        else
          fail = true
          break
        end
      end
      flash[:message] = "Import successful, #{StringUtils.pluralize(n, 'allocation')} created" unless fail
    end
    if fail || !@errors.empty?
      @allocations = []
      flash[:error] = "Import failed, see below for details"
    end
    render :action => 'export_import'
  end
  
  def toggle_pix
    if session[:allocation_load_toggle_pix] == "HIDE"
      session[:allocation_load_toggle_pix] = "SHOW"
    else
      session[:allocation_load_toggle_pix] = "HIDE"
    end
    
    respond_to do |format|
      format.html { 
        export_import
        render export_import_allocations_path
      }
      format.js  { do_rjs_toggle_pix }
    end
  end
  
  def toggle_image_button
    "&nbsp;&nbsp; #{link_to pix_button_text, toggle_pix_allocations_path, html_options = {:class=> "button"} }"
  end

  private
  def stream_csv
    filename = params[:action] + ".csv"    

    #this is required if you want this to work with IE        
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain" 
      headers['Cache-Control'] = 'private'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
      headers['Expires'] = "0" 
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
    end

    render :text => Proc.new { |response, output|
      csv = FasterCSV.new(output, :row_sep => "\r\n") 
      yield csv
    }
  end  
  
  def do_rjs_toggle_pix  
    render :update do |page|
      if session[:allocation_load_toggle_pix] == "HIDE"
        page.show :show_images
        page.visual_effect :squish, :image1, :duration => 0.5
        page.visual_effect :squish, :image2, :duration => 0.5
        page.visual_effect :blind_up, "hide_images", :duration => 0.2
        page.visual_effect :blind_down, "show_images", :duration => 1
      else
        page.visual_effect :blind_down, "image1", :duration => 1
        page.visual_effect :blind_down, "image2", :duration => 1
        page.visual_effect :blind_up, "show_images", :duration => 0.2
        page.visual_effect :blind_down, "hide_images", :duration => 1
      end
    end
  end
  
  def array_to_string(ary)
    return "" if ary.nil? or ary.size == 0
    buf = ary.pop
    for a in ary
      buf += ", #{a}"
    end
    buf
  end
end
