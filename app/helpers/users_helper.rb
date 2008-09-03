module UsersHelper  
  def pix_button_text
    return "Show Images" if session[:user_load_toggle_pix] == "HIDE"
    "Hide Images"
  end
  
  def pix_button_display_style action
    return "display:none;" if session[:user_load_toggle_pix] == action
    "display:block;"
  end
  
  def pix_display_style
    return "display:none;" if session[:user_load_toggle_pix] == "HIDE"
    "display:block;"
  end
  
  def user_filter_link start_tag, end_tag
    if session[:users_start_filter] == start_tag
      "<b>#{filter_label start_tag, end_tag}</b>"
    else
      link_to filter_label(start_tag, end_tag), :action => :list, 
        :start_filter => start_tag, :end_filter => end_tag
    end
  end

  private

  def filter_label start_tag, end_tag
    return start_tag if start_tag == end_tag
    "#{truncate(start_tag, 15)} to #{truncate(end_tag, 15)}"
  end
end
