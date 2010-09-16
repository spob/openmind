class PortalController < ApplicationController
  auto_complete_for :user, :email
  
  def index
    if !logged_in? || !current_user.try(:can_view_portal?)
      flash[:error] = "You don't have access to the partner portal"
      redirect_to home_path
    else
      if current_user.can_specify_email_in_portal?
        session[:portal_email] = params[:user][:email] if params[:user] && params[:user][:email]
        session[:portal_email] = nil if params[:reset]
      end
      session[:portal_email] ||= current_user.email
#      @orgs = current_user.portal_orgs.collect(&:external_org_id)
      @customers = PortalUserOrgMap.portal_end_customer_orgs.by_email(session[:portal_email]).collect{ |uo| uo.portal_org.portal_customers }.flatten
      @technical_consultants = PortalUserOrgMap.portal_reseller_orgs.by_email(session[:portal_email]).collect{ |uo| uo.portal_org.portal_certified_consultants.technical }.flatten
      @sales_consultants = PortalUserOrgMap.portal_reseller_orgs.by_email(session[:portal_email]).collect{ |uo| uo.portal_org.portal_certified_consultants.sales }.flatten
      @nfrs = PortalUserOrgMap.portal_reseller_orgs.by_email(session[:portal_email]).collect{ |uo| uo.portal_org.portal_nfrs }.flatten
      @tickets = PortalUserOrgMap.by_email(session[:portal_email]).collect{ |uo| uo.portal_org.portal_support_incidents }.flatten
      @user = User.new(:email => session[:portal_email])
    end
  end
end
