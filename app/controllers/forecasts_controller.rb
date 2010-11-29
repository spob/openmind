class ForecastsController < ApplicationController
  before_filter :login_required
  before_filter :fetch_forecast, :only => [:edit, :update, :destroy]

  verify :method => :post, :only => [:create],
         :redirect_to => {:action => :index}
  verify :method => :put, :only => [:update],
         :redirect_to => {:action => :index}
  verify :method => :delete, :only => [:destroy],
         :redirect_to => {:action => :index}

  def index
    redirect_to portal_index_path
  end

  def new
    can_forecast?
    @forecast = Forecast.new(:partner_representative => current_user.full_name)
  end

  def create
    if can_forecast?
      @forecast = Forecast.new(params[:forecast])
      @forecast.enterprise = current_user.enterprise
      @forecast.user = current_user
      if @forecast.save
        flash[:notice] = "Opportunity #{@forecast.account_name} was successfully created."
        redirect_to portal_index_path
      else
        render :action => 'new'
      end
    end
  end

  def edit
    can_forecast? true
  end

  def update
    if can_forecast? true
      if @forecast.update_attributes(params[:forecast])
        flash[:notice] = "Opportunity #{@forecast.account_name} was successfully updated."
        redirect_to portal_index_path
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    @forecast.update_attribute(:deleted_at, Time.now)
    flash[:notice] = "Opportunity #{@forecast.account_name} was successfully deleted."
    redirect_to portal_index_path
  end

  private

  def can_forecast? allow_impersonation=false
    return true if current_user.can_view_forecasts?
    return true if current_user.can_specify_email_in_portal? && allow_impersonation
    flash[:error] = "You do not have access to that page"
    redirect_to portal_index_path
    false
  end

  def fetch_forecast
    @forecast = Forecast.find(params[:id])
  end
end
