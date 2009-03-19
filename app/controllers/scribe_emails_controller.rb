class ScribeEmailsController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create ],
    :redirect_to => { :controller => :ideas, :action => :index }
  
  def create
    ScribeEmail.deliver_scribe_feedback_notification(params[:email],
      params[:comments])

    flash[:notice] = "Your feedback has been received"

    redirect_to :action => :show
  end
  
  def new
    redirect_to :controller => 'account', :action => 'login' if logged_in?
  end

  def show
  end
end