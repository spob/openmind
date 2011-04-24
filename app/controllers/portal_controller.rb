class PortalController < ApplicationController
  auto_complete_for :user, :email

  def index
    if can_view_portal?
#      @orgs = current_user.portal_orgs.collect(&:external_org_id)
      @customers = PortalUserOrgMap.active.portal_end_customer_orgs.by_email(session[:portal_email]).collect { |uo| uo.portal_org.portal_customers }.flatten

      @entitlements = PortalUserOrgMap.active.by_email(session[:portal_email]).collect { |uo| uo.portal_org.portal_entitlements }.flatten
    end
  end

  def forecasts
    if current_user.can_view_forecasts? || current_user.can_specify_email_in_portal?
      @user = User.find_by_email(session[:portal_email])
      @forecasts = @user.enterprise.forecasts.active.sort { |x, y| Forecast.stages[x.stage] <=> Forecast.stages[y.stage] } if @user
      @forecasts ||= []
    else
      flash[:error] = "You don't have access to the partner portal"
      redirect_to portal_index_path
    end
  end

  def technical_consultants
    if can_view_portal?
      @technical_consultants = PortalUserOrgMap.active.portal_reseller_orgs.by_email(session[:portal_email]).collect { |uo| uo.portal_org.portal_certified_consultants.technical }.flatten
    end
  end

  def sales_consultants
    if can_view_portal?
      @sales_consultants = PortalUserOrgMap.active.portal_reseller_orgs.by_email(session[:portal_email]).collect { |uo| uo.portal_org.portal_certified_consultants.sales }.flatten
    end
  end

  def nfrs
    if can_view_portal?
      @nfrs = (PortalUserOrgMap.active.portal_reseller_orgs.by_email(session[:portal_email]).collect { |uo| uo.portal_org.portal_nfrs } +
          PortalUserOrgMap.active.portal_reseller_orgs.by_email(session[:portal_email]).collect { |uo| uo.portal_org.portal_customers }).flatten
    end
  end

  def tickets
    if can_view_portal?
      @tickets = PortalUserOrgMap.active.by_email(session[:portal_email]).collect { |uo| uo.portal_org.portal_support_incidents }.flatten.sort { |x, y| y.opened_at <=> x.opened_at }
    end
  end

  def users
    if can_view_portal?
      @users = @user.enterprise.users if @user
      @users ||= []
    end
  end

  def show_serial_number
    if !current_user.can_specify_email_in_portal?
      flash[:error] = "You don't have access to the partner portal"
      redirect_to home_path
    else
      @serial_number = SerialNumber.find(params[:id])
    end
  end

  private

  def can_view_portal?
    if !logged_in? || !current_user.try(:can_view_portal?)
      flash[:error] = "You don't have access to the partner portal"
      redirect_to home_path
      return false
    end
    if current_user.can_specify_email_in_portal?
      session[:portal_email] = params[:user][:email] if params[:user] && params[:user][:email]
      session[:portal_email] = nil if params[:reset]
    end
    session[:portal_email] ||= current_user.email
    @user = User.find_by_email(session[:portal_email])
    true
  end
end
