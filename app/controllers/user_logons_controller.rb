class UserLogonsController < ApplicationController
  before_filter :login_required
  access_control [:new, :commit, :index, :show, :edit, :create, :update,
    :destroy] => 'sysadmin'

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create, :commit ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }

  def index
    @user_logons = UserLogon.list params[:page], current_user.row_limit
  end
end
