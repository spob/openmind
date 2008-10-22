class LinkSetsController < ApplicationController
  before_filter :login_required
  access_control [:index, :show, :new,  :edit, :create, :update, :destroy ] => 'sysadmin'

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create, :sort ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }
  
  def index
    new
    puts "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    @link_sets = LinkSet.list params[:page], current_user.row_limit
  end

  def show
    puts "==========================================="
    @link_set = LinkSet.find(params[:id])
  end

  def new
    @link_set = LinkSet.new
  end

  def create
    @link_set = LinkSet.new(params[:link_set])
    @link_set.links << Link.new(:name => 'Link 1...', :url => 'URL 1')
    if @link_set.save
      flash[:notice] = "Link Set #{@link_set.name} was successfully created."
      redirect_to edit_link_set_path(@link_set)
    else
      @link_sets = LinkSet.list params[:page], current_user.row_limit
      render :action => :index
    end
  end

  def edit
    @link_set = LinkSet.find(params[:id])
  end

  def update
    @link_set = LinkSet.find(params[:id])
    if @link_set.update_attributes(params[:link_set])
      flash[:notice] = "Link Set #{@link_set.name} was successfully updated."
      redirect_to link_set_path(@link_set)
    else
      render :action => :edit
    end
  end

  def destroy
    link_set = LinkSet.find(params[:id])
    name = link_set.name
    link_set.destroy
    flash[:notice] = "Link Set #{name} was successfully deleted."
    redirect_to link_sets_url
  end
  
  def update_sort
    puts ".....................................here"
    @link_set = LinkSet.find(params[:id])
    @link_set.links.each do |link|      
      # we must add one to compensate for the zero based index.
      link.position = params['linklist'].index(link.id.to_s) + 1
      link.save
    end
    render :nothing => true
  end
end
