class AttachmentsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_filter :login_required, :except => [ :download ]
  access_control [:index, :edit, :update, :destroy] => 'prodmgr | sysadmin'

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
      redirect_on_error params, "Please specify a file to upload"
      return
    end
    if not_from_comment? params
      @attachment = Attachment.new(params[:attachment])
    else
      @attachment = CommentAttachment.new(params[:attachment])
      comment = Comment.find params[:comment_id]
      @attachment.comment = comment
    end
    @attachment.user = current_user

    if from_comment? params 
      unless @attachment.image?
        redirect_on_error params, "Uploads are restricted to image files only"
        return
      end
      if @attachment.size > APP_CONFIG['max_file_upload_size'].to_i * 1024
        redirect_on_error params, 
          "Upload exceeds maximum file size of #{number_to_human_size(APP_CONFIG['max_file_upload_size'].to_i * 1024)}"
        return
      end
    end
    Attachment.transaction do
      if @attachment.save
        flash[:notice] = "Your file has been uploaded successfully"
        if @attachment.class.to_s == 'Attachment'
          redirect_to attachment_path(@attachment)
        else
          redirect_to calc_return_path(@attachment.comment)
        end
      else
        redirect_on_error params, "There was a problem submitting your attachment"
      end
    end
  end
  
  private
  
  def redirect_on_error params, err_msg
    flash[:error] =  err_msg
    if not_from_comment? params
      index
      render :action => :index
    else
      redirect_to attach_comment_path(Comment.find(params[:comment_id]))
    end
  end
  
  def calc_return_path comment
    if comment.class.to_s == 'TopicComment'
      topic_path(comment.topic.id, :anchor => comment.id.to_s)
    else
      url_for(:controller => 'ideas', :action => 'show', :id => comment.idea, 
        :selected_tab => "COMMENTS", :anchor => comment.id.to_s)
    end
  end
  
  def from_comment? params
    !not_from_comment? params
  end
  
  def not_from_comment? params
    params[:comment_id].nil? or params[:comment_id].blank?
  end
end