class LookupCodesController < ApplicationController
  before_filter :login_required
  access_control :DEFAULT => 'sysadmin'

  def index
    @types = [
      ["Enterprise Type",  "EnterpriseType"],
      ["Forum Group",  "ForumGroup"],
      ["Release Status",  "ReleaseStatus"],
      ["Release Dependency Group",  "ReleaseDependencyGroup"],
      ["Custom Field",  "CustomField"],
      ["Account Exec",  "AccountExec"],
      ["RBM",  "Rbm"],
      ["Region",  "Region"]
    ]
    @lookup_codes = LookupCode.list params[:page], current_user.row_limit
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }

  def show
    @lookup_code = LookupCode.find(params[:id])
  end

  def create
    if params[:lookup_code][:code_type].blank?
      flash[:error] = "Please select a Lookup Type"
      index
      render :action => 'index'
      return
    end
    command = "#{params[:lookup_code][:code_type]}.new(params[:lookup_code])"
    #    print command
    @lookup_code = eval command
    if @lookup_code.save
      flash[:notice] = "LookupCode #{@lookup_code.short_name} was successfully created."
      redirect_to lookup_codes_path
    else
      index
      render :action => 'index'
    end
  end

  def edit
    @lookup_code = LookupCode.find(params[:id])
  end

  def update
    @lookup_code = LookupCode.find(params[:id])
    if @lookup_code.update_attributes(params[:lookup_code])
      flash[:notice] = "LookupCode '#{@lookup_code.short_name}' was successfully updated."
      redirect_to lookup_codes_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    lookup_code = LookupCode.find(params[:id])
    short_name = lookup_code.short_name
    lookup_code.destroy
    flash[:notice] = "LookupCode was #{short_name} successfully deleted."
    redirect_to lookup_codes_path
  end
end
