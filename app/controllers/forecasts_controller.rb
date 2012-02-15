class ForecastsController < ApplicationController
  before_filter :login_required
  before_filter :fetch_forecast, :only => [:edit, :update, :destroy]

  verify :method      => :post, :only => [:create],
         :redirect_to => {:action => :index}
  verify :method      => :put, :only => [:update],
         :redirect_to => {:action => :index}
  verify :method      => :delete, :only => [:destroy],
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
      params[:forecast][:product_ids] ||= []
      @forecast                       = Forecast.new(params[:forecast])
      @forecast.enterprise            = current_user.enterprise
      @forecast.user                  = current_user
      if @forecast.save
        flash[:notice] = "Opportunity #{@forecast.account_name} was successfully created."
        redirect_to forecasts_portal_path
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
      params[:forecast][:product_ids] ||= []
      if @forecast.update_attributes(params[:forecast])
        flash[:notice] = "Opportunity #{@forecast.account_name} was successfully updated."
        redirect_to forecasts_portal_path
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    @forecast.update_attribute(:deleted_at, Time.now)
    flash[:notice] = "Opportunity #{@forecast.account_name} was successfully deleted."
    redirect_to forecasts_portal_path
  end

  def auto_complete_for_forecast_account_name
    search_txt     = ".*#{params[:forecast][:account_name]}.*"
    @account_names = PortalUserOrgMap.active.portal_end_customer_orgs.by_email(session[:portal_email]).collect { |uo| uo.portal_org.portal_customers }.flatten.map { |x| x.portal_org }.uniq.find_all { |x| Regexp.new(search_txt, Regexp::IGNORECASE).match(x.org_name) }.sort
    puts @account_names
    render :inline => "<%= auto_complete_result(@account_names, 'org_name') %>"
  end


#    t.integer  "enterprise_id",                        :null => false
#    t.integer  "user_id",                              :null => false
#    t.string   "partner_representative", :limit => 50, :null => false
#    t.string   "account_name",           :limit => 50, :null => false
#    t.string   "rbm",                    :limit => 50, :null => false
#    t.string   "account_exec",           :limit => 50, :null => false
#    t.string   "location",               :limit => 50, :null => false
#    t.string   "stage",                  :limit => 25, :null => false
#    t.string   "product",                :limit => 50, :null => false
#    t.date     "close_at",                             :null => false
#    t.integer  "amount",                               :null => false
#    t.string   "comments"
#    t.datetime "deleted_at"
#    t.datetime "created_at"
#    t.datetime "updated_at"


  # Generate a csv file of users and enterprises
  def export
    response = ""
    csv      = FasterCSV.new(response, :row_sep => "\r\n")
    csv     << ["Enterprise", "Account", "Address1", "Address2", "City", "State", "Postal Code", "Country",
                "Region", "Partner Rep", "Scribe RBM", "Scribe Account Exec",
                "Product", "Adapters", "Amount", "Close Date", "Stage", "Stage Rank", "Comments", "Created At", "Updated At"]

    Forecast.export_sort.each do |f|
      csv << [f.enterprise.name,
              f.account_name,
              f.address1,
              f.address2,
              f.city,
              f.state,
              f.postal_code,
              f.country,
              f.region.description,
              f.partner_representative,
              f.rbm.description,
              f.account_exec.description,
              f.product,
              f.products.present? ? f.products.collect { |p| p.name }.join(", ") : "",
              f.amount,
              f.close_at,
              f.stage,
              Forecast.stages[f.stage],
              f.comments,
              f.created_at,
              f.updated_at,
      ]
    end
    CsvUtils.setup_request_for_csv headers, request, "forecasts.csv"
    render :text => response
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
