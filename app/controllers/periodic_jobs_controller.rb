class PeriodicJobsController < ApplicationController
  before_filter :login_required
  access_control [:edit, :update, :destroy, :show, :index, :rerun, :runnow] => 'sysadmin'
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:rerun, :runnow ],
    :redirect_to => :periodic_jobs_path
  #  verify :method => :put, :only => [ :update ],
  #    :redirect_to => periodic_jobs_path
  #  verify :method => :delete, :only => [ :destroy ],
  #    :redirect_to => periodic_jobs_path
  
  def index
    @jobs = PeriodicJob.list params[:page], current_user.row_limit
  end
  
  def rerun
    job = PeriodicJob.find(params[:id])
    RunOncePeriodicJob.create(
      :job => job.job)
    flash[:notice] = "Job has been scheduled to run one time."
    redirect_to periodic_jobs_path
  end

  def runnow
    job = PeriodicJob.find(params[:id])
    job.update_attribute(:next_run_at, Time.now)
    flash[:notice] = "Job has been scheduled to run immediately."
    redirect_to periodic_jobs_path
  end
end