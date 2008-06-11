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
end
