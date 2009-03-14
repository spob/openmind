module EnterprisesHelper  
  def enterprise_filter_link start_tag, end_tag
    if session[:enterprise_start_filter] == start_tag
      "<b>#{filter_label start_tag, end_tag}</b>"
    else
      link_to filter_label(start_tag, end_tag), enterprises_path( 
        :start_filter => start_tag, :end_filter => end_tag)
    end
  end

  private

  def filter_label start_tag, end_tag
    return start_tag if start_tag == end_tag
    "#{truncate(start_tag, :length => 15)} to #{truncate(end_tag, :length => 15)}"
  end
end
