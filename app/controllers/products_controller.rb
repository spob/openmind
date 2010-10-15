class ProductsController < ApplicationController
  before_filter :login_required, :except => [:index, :show ]
  access_control [:new, :commit, :edit, :create, :update, :destroy] => 'prodmgr'
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create ],
  :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
  :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
  :redirect_to => { :action => :index }
  
  def index
    if params[:form_based] == "yes"
      session[:active_products_only] = (params[:active_products_only].nil? ? "no" : "yes")
    else
      session[:active_products_only] ||= "yes"
      session[:active_products_only] = params[:active_products_only] unless params[:active_products_only].nil?
    end
    @products = Product.list session[:active_products_only] == "yes",
    params[:page], (logged_in? ? current_user.row_limit : 10)
  end
  
  def show
    @product = Product.find(params[:id])
  end
  
  #  def new
  #    @product = Product.new
  #  end
  
  def create
    @product = Product.new(params[:product])
    if @product.save
      flash[:notice] = "Product #{@product.name} was successfully created."
      redirect_to products_path
    else
      index
      render :action => :index
    end
  end
  
  def edit
    @product = Product.find(params[:id])
  end
  
  def update
    @product = Product.find(params[:id])
    if @product.update_attributes(params[:product])
      flash[:notice] = "Product #{@product.name} was successfully updated."
      redirect_to product_path(@product)
    else
      render :action => :edit
    end
  end
  
  def destroy
    product = Product.find(params[:id])
    name = product.name
    product.destroy
    flash[:notice] = "Product #{name} was successfully deleted."
    redirect_to products_url
  end
end
