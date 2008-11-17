class AttachmentsController < ApplicationController
  before_filter :login_required, :except => [ :show ]
  access_control [:index, :edit, :create, :update, :destroy] => 'prodmgr | sysadmin'

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }

  def index
    @attachments = Attachment.list params[:page], current_user.row_limit
  end

  def edit
    @attachment = Attachment.find(params[:id])
  end

  def update
    @attachment = Attachment.find(params[:id])
    if @attachment.update_attributes(params[:attachment])
      flash[:notice] = "Attachment '#{@attachment.filename}' was successfully updated."
      redirect_to attachment_path(@attachment)
    else
      render :action => :edit
    end
  end
  
  #  def new
  # # 	@attachment = Attachment.new # end

  def show
    @attachment = Attachment.find(params[:id])
  end

  def destroy
    attachment = Attachment.find(params[:id])
    name = attachment.filename
    attachment.destroy
    flash[:notice] = "Attachment #{name} was successfully deleted."
    redirect_to attachments_url
  end

  def download
    @attachment = Attachment.find(params[:id])
    send_data @attachment.data, :filename => @attachment.filename,
      :type => @attachment.content_type
  end

  def create
    if params[:attachment][:file].blank?
      flash[:error] = "Please specify a file to upload"
      index
      render :action => :index
      return
    end
    @attachment = Attachment.new(params[:attachment])
    @attachment.user = current_user

    if @attachment.save
      flash[:notice] = "Your file has been uploaded successfully"
      redirect_to attachment_path(@attachment)
    else
      flash[:error] = "There was a problem submitting your attachment."
      index
      render :action => :index
    end
  end
end