# To change this template, choose Tools | Templates
# and open the template in the editor.

class AttachmentsSweeper < ActionController::Caching::Sweeper
  observe Attachment # This sweeper is going to keep an eye on the Attachment model

  # If our sweeper detects that an attachment was created call this
  def after_save(attachment)
    expire_cache_for(attachment)
  end

  # If our sweeper detects that an attachment was deleted call this
  def after_destroy(attachment)
    expire_cache_for(attachment)
  end

  def before_attachments_search
    expire_fragment(%r{attachments/list_attachments\.action_type=search&page=(\d)+&user_id=#{current_user.id}})
  end

  private
  def expire_cache_for(record)
    # Expire a fragment
    expire_fragment(%r{attachments/list_attachments.*})
    #    expire_fragment(:controller => 'attachments', :action => 'index',
    #      :page => params[:page] || 1)
  end
end