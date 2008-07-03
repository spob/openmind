module PollsHelper
  
  def add_option_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :poll_options, :partial => 'poll_option', 
        :object => PollOption.new(:description => "...")
    end
  end
  
  
  def details_button_text
    return "Show Details" if session[:polls_show_toggle_detail] == "HIDE"
      "Hide Details"
  end
  
  def details_display_style
    return "display:none;" if session[:polls_show_toggle_detail] == "HIDE"
    "display:block;"
  end
  
  def details_button_display_style action
    return "display:none;" if session[:polls_show_toggle_detail] == action
    "display:block;"
  end
end
