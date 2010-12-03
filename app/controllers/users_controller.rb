class UsersController < ApplicationController
  before_filter :login_required, :except => [:lost_password, :fetch_otp]
  access_control [:new, :edit, :create, :update, :destroy, :reset_password] => 'sysadmin',
  [:index, :list, :show, :search, :next, :previous, :export, :export_import,
  :import, :process_imported] => '(sysadmin | allocmgr)'
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update, :update_profile, :reset_password, :process_imported, :import, :fetch_otp ],
  :redirect_to => { :action => :list }
  
  def index
    list
    render :action => 'list'
  end
  
  def list
    session[:users_start_filter] = params[:start_filter] unless params[:start_filter].nil?
    session[:users_end_filter] = params[:end_filter] unless params[:end_filter].nil?
    session[:users_start_filter] = "All" if session[:users_start_filter].nil?
    session[:users_end_filter] = "All" if session[:users_end_filter].nil?
    unless session[:users_start_filter].nil?
      session[:users_search] = nil
    end
    set_start_stop_tags
    @users = User.list params[:page], current_user.row_limit, session[:users_start_filter], 
    session[:users_end_filter], nil
  end
  
  def search
    session[:users_start_filter] = "All" 
    session[:users_end_filter] = "All"
    session[:users_search] = (params[:user] ? params[:user][:email] : "")
    @user = User.new(:email => session[:users_search])
    #    params[:search] = StringUtils.sanitize_search_terms params[:search]
    if @user.email.blank?
      list
      render :list
      return
    end
    
    set_start_stop_tags
    begin
      search_results = User.search_for_ids @user.email, :order => :email
      #      search_results = User.find_by_solr(params[:search], :lazy => true).docs.collect(&:id)
    rescue RuntimeError => e
      flash[:error] = "An error occurred while executing your search. Perhaps there is a problem with the syntax of your search string."
      logger.error(e)
      redirect_to :action => 'list'
    else
      @users = User.list params[:page], 999,
      session[:users_start_filter],
      session[:users_end_filter],
      search_results
      render :action => 'list'
    end
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def next
    user = User.find(params[:id])
    users = User.next(user.email)
    if users.empty?
      @user = user
    else
      @user = users.first
    end
    render :action => 'show'
  end
  
  def previous
    user = User.find(params[:id])
    users = User.previous(user.email)
    if users.empty?
      @user = user
    else
      @user = users.first
    end
    render :action => 'show'
  end
  
  def process_imported
    counter = 0
    for user in User.imported_users
      user.reset_password
      user.save
      EmailNotifier.deliver_signup_notification(user)
      counter = counter + 1
    end
    flash[:notice] = "Processed #{StringUtils.pluralize(counter, 'imported user')}"
    redirect_to :action => 'list'
  end
  
  def reset_password
    @user = User.find(params[:id])
    @user.reset_password
    if @user.save
      flash[:notice] = "The password for #{@user.login} was reset and an email was sent to that user."
      EmailNotifier.deliver_reset_notification(@user)
      redirect_to :action => 'show', :id => @user
    else
      setup_session_properties
      render :action => 'show', :id => @user
    end
  end
  
  def create 
    params[:user][:role_ids] ||= []
    params[:user][:group_ids] ||= []
    @user = User.new(params[:user])
    @user.first_name = @user.first_name.try(:strip)
    @user.last_name = @user.last_name.try(:strip)
    @user.login = @user.login.try(:strip)
    @user.hide_contact_info = params[:user][:hide_contact_info]
    if CustomField.users_custom_boolean1
      @user.custom_boolean1 = params[:user][:custom_boolean1]
    end
    @user.identity_url = add_trailing_slash params[:user][:identity_url]
    @user.new_random_password
    parse_error = nil
    if allocmgr? and !@user.initial_allocation.nil? and @user.initial_allocation.length > 0
      qty = Integer(@user.initial_allocation) rescue parse_error = "Initial allocation quantity must be an integer value"
      parse_error = "Initial allocation quantity cannot be less than zero" if parse_error.nil? and qty < 0
      if !parse_error.nil?
        flash[:error] = parse_error
        setup_session_properties
        render :action => 'new'
        return
      elsif qty > 0
        alloc = UserAllocation.new(
                                   :quantity => qty, 
                                   :comments => "",
        :expiration_date => Allocation.calculate_expiration_date)
      end
    end
    if @user.save
      unless alloc.nil?
        alloc.user = @user
        alloc.save
      end
      flash[:notice] = "User #{@user.login} was successfully created."
      redirect_to :action => 'list'
    else
      setup_session_properties
      render :action => 'new'
    end
  end
  
  def fetch_otp
    user = nil
    trusted_sites = (APP_CONFIG['otp_trusted_sites'] || "")
    if Regexp.new(trusted_sites).match(request.remote_ip )
      user = User.find_by_email(params[:login])
    else
      logger.warn("Request for a otp from an untrusted site: #{request.remote_ip} is not in #{APP_CONFIG['otp_trusted_sites']}")
    end
    logger.info("Requested otp from #{request.remote_ip}")
    respond_to do |format|
      format.xml do
        if user.nil?
#          render :nothing => true, :status => 404
          render :xml => User.new(:one_time_password => "NOSUCHUSER").otp_to_xml
        else
          user.new_otp
          user.save!
          render :xml => user.otp_to_xml
        end
      end
    end
  end
  
  def lost_password
    return unless request.post?    
    @email = params[:email] # needed to remember email info if fails
    user = User.find_by_email(@email)
    if user.nil?
      flash[:notice] = "No such user #{@email}"
    elsif !user.active
      flash[:notice] = "Account for user #{@email} is disabled"
    else
      user.reset_password
      if user.save
        flash[:notice] = "The password for #{user.login} has been reset. You will receive an email with the new password"
        EmailNotifier.deliver_reset_notification(user)
        redirect_back_or_default home_path
      end
    end
  end
  
  def auto_complete_for_user_email
    search_txt = "%#{params[:user][:email]}%"
    @users = User.find(:all, :conditions => ['email LIKE ? or first_name like ? or last_name like ?', 
    search_txt, search_txt, search_txt],
    :order => 'email ASC', :limit => 10) 
    render :inline => "<%= auto_complete_result(@users, 'email') %>"
  end
  
  def new
    @user = User.new(:initial_allocation => 0)
    # default timezone
    @user.time_zone = APP_CONFIG['default_user_timezone']
    setup_session_properties
  end
  
  def update
    params[:user][:role_ids] ||= []
    params[:user][:group_ids] ||= []
    @user = User.find(params[:id])
    
    # if the password was updated, force a password change
    params[:user][:force_change_password] = 1 unless params[:user][:password].nil? or params[:user][:password].length == 0
    params[:user][:identity_url] = add_trailing_slash params[:user][:identity_url]
    
    if @user.update_attributes(params[:user])
      flash[:notice] = "User #{@user.login} was successfully updated."
      redirect_to :action => 'show', :id => @user
    else
      @user.errors.each{|attr,msg| puts ">>>>>>>#{attr} - #{msg}" }
      setup_session_properties
      render :action => 'edit'
    end
  end
  
  def edit_profile
    @user = current_user
  end
  
  def update_profile
    @user = User.find(params[:id])
    @user.first_name = params[:user][:first_name]
    @user.last_name = params[:user][:last_name]
    @user.time_zone = params[:user][:time_zone]
    @user.topic_notification_digests = params[:user][:topic_notification_digests]
    @user.row_limit = params[:user][:row_limit]
    @user.identity_url = add_trailing_slash params[:user][:identity_url]
    @user.hide_contact_info = params[:user][:hide_contact_info]
    @user.watch_on_vote = params[:user][:watch_on_vote]
    if @user.save
      flash[:notice] = "User #{@user.login}'s profile was successfully updated."
      #      redirect_back_or_default home_path
      redirect_to :controller => 'ideas', :action => 'list'
      # may have changed # of rows to display...clear any impacted cached pages
      expire_fragment(%r{attachments/list_attachments.page=(\d)+&user_id=#{current_user.id}})
    else
      render :action => 'edit_profile'
    end
  end
  
  def destroy
    user = User.find(params[:id])
    email = user.email
    user.destroy
    flash[:notice] = "User #{email} was successfully deleted."
    redirect_to :action => 'list'
  end
  
  def edit
    @user = User.find(params[:id])
    setup_session_properties
  end
  
  def export_import
    session[:user_load_toggle_pix] ||= "HIDE"
    @errors = []
    @users = []
    @enterprises = []
  end
  
  # Generate a csv file of users and enterprises
  def export
    
    response = ""
    csv = FasterCSV.new(response, :row_sep => "\r\n")
    
    csv << ["email",
        "first name", 
        "last name", 
        "enterprise",
        "allocations mgr (Y|N)",
        "voter (Y|N)"
    ]
    CsvUtils.setup_request_for_csv headers, request, "users.csv"
    render :text => response
  end
  
  def import 
    @parsed_file=CSV::Reader.parse(params[:dump][:file])
    @errors = []
    @users = []
    @enterprises = []
    
    allocmgr_role = Role.find_by_title "allocmgr"
    voter_role = Role.find_by_title "voter"
    
    n = -1
    @parsed_file.each do |row|
      if n == -1
        # skip the first line -- it's the header
        n = 0
        next
      end
      n += 1
      
      email = row[0]
      first_name = row[1]
      last_name = row[2]
      enterprise_name = row[3]
      allocation_mgr = row[4]
      voter = row[5]
      
      if enterprise_name.blank?
        @errors << "Enterprise must be specified for '#{email}'"
        next
      end
      # Create a dummy enterprise for now...
      enterprise = Enterprise.new(:name => enterprise_name) if enterprise.nil?
      
      if 
        user = User.new(:email => email, :first_name => first_name,
                        :last_name => last_name, :enterprise => enterprise,
                        :password => "Dummy", :password_confirmation => "Dummy",
        :activation_code => "SKIP")
        if yes? allocation_mgr
          user.roles << allocmgr_role
        end
        if yes? voter
          user.roles << voter_role
        end
      end
      if !user.valid?
        user.errors.each do |attr, msg|
          @errors << "#{email}: #{attr} #{msg}"
        end
      else
        @users << user
      end
    end
    fail = false
    if @errors.empty?
      n = 0
      for user in @users
        enterprise_name = user.enterprise.name
        enterprise = Enterprise.find_by_name(enterprise_name)
        if enterprise.nil?
          enterprise = Enterprise.create(:name => enterprise_name) 
          @enterprises <<  enterprise
        end
        user.enterprise = enterprise
        if user.save
          n += 1 
        else
          fail = true
          break
        end
      end
      flash[:notice] = "Import successful, #{StringUtils.pluralize(n, 'user')} created, #{StringUtils.pluralize(@enterprises.length, 'enterprise')} created" unless fail
    end
    if fail || !@errors.empty?
      @users = []
      @enterprises = []
      flash[:error] = "Import failed, see below for details"
    end
    render :action => 'export_import'
  end
  
  def toggle_pix
    if session[:user_load_toggle_pix] == "HIDE"
      session[:user_load_toggle_pix] = "SHOW"
    else
      session[:user_load_toggle_pix] = "HIDE"
    end
    
    respond_to do |format|
      format.html { 
        export_import
        render :action => 'export_import'
      }
      format.js  { do_rjs_toggle_pix }
    end
  end
  
  def toggle_image_button
    "&nbsp;&nbsp; #{link_to pix_button_text, 
    options = { :action => 'toggle_pix'}, 
    html_options = {:class=> "button"} }"
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
      if session[:user_load_toggle_pix] == "HIDE"
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
  
  def setup_session_properties
    @enterprises = Enterprise.active   
  end
  
  def yes? str
    return false if str.nil?
    str.upcase == "Y" || str.upcase == "YES" || str.upcase == "T" || str.upcase == "TRUE"
  end
  
  def add_trailing_slash str
    str = str + '/' unless str.blank? or str =~ /\/$/
    str
  end
  
  def set_start_stop_tags
    count = User.count
    if count > 100
      @tag1_begin = User.find(:first, :select => "email", :order => "email").email
      @tag1_end = User.find(:first, :select => "email", :offset => count/5, :order => "email").email
      @tag2_begin = User.find(:first, :select => "email", :offset => count/5 + 1, :order => "email").email
      @tag2_end = User.find(:first, :select => "email", :offset => 2*count/5, :order => "email").email
      @tag3_begin = User.find(:first, :select => "email", :offset => 2*count/5 + 1, :order => "email").email
      @tag3_end = User.find(:first, :select => "email", :offset => 3*count/5, :order => "email").email
      @tag4_begin = User.find(:first, :select => "email", :offset => 3*count/5 + 1, :order => "email").email
      @tag4_end = User.find(:first, :select => "email", :offset => 4*count/5, :order => "email").email
      @tag5_begin = User.find(:first, :select => "email", :offset => 4*count/5 + 1, :order => "email").email
      @tag5_end = User.find(:first, :select => "email", :offset => count-1, :order => "email").email
    end
  end
end
