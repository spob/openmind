module AttachmentsHelper
  def download_url attachment
    url_for :controller => 'download',
      :action => ((attachment.alias.nil? or attachment.alias.blank?) ? attachment.id : attachment.alias), :only_path => false
  end

  def html_url attachment
    url_for :controller => 'html',
      :action => ((attachment.alias.nil? or attachment.alias.blank?) ? attachment.id : attachment.alias), :only_path => false
  end
end