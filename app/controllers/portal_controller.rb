class PortalController < ApplicationController
  def index
    if !logged_in? || !current_user.try(:can_view_portal?)
      flash[:error] = "You don't have access to the partner portal"
      redirect_to home_path
    else
      if current_user.can_specify_email_in_portal?
        session[:portal_email] = params[:email] if params[:email]
        session[:portal_email] = nil if params[:reset]
      end
      session[:portal_email] ||= current_user.email
      @orgs = current_user.portal_orgs.collect(&:external_org_id)
      @customers = PortalUserOrgMap.by_email(session[:portal_email]).collect{ |uo| uo.portal_org.portal_customers }.flatten
      @technical_consultants = PortalUserOrgMap.by_email(session[:portal_email]).collect{ |uo| uo.portal_org.portal_certified_consultants.technical }.flatten
      @sales_consultants = PortalUserOrgMap.by_email(session[:portal_email]).collect{ |uo| uo.portal_org.portal_certified_consultants.sales }.flatten
      @nfrs = PortalUserOrgMap.by_email(session[:portal_email]).collect{ |uo| uo.portal_org.portal_nfrs }.flatten
      @tickets = PortalUserOrgMap.by_email(session[:portal_email]).collect{ |uo| uo.portal_org.portal_support_incidents }.flatten
    end
  end
end
