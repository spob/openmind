module PollsHelper
  require 'rubygems'
  require 'google_chart'
    
  def add_option_link(name)
    link_to_function name, :class=> 'insideFormTitle' do |page|
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

  def google_pie_chart(data, options = {})
    
    width =  options[:width] ||= 350
    height = options[:height] ||= 100
    
    GoogleChart::PieChart.new("#{width}x#{height}", "Pie Chart" ,true) do |pc|
      
      data.each do  |k,v|    
        pc.data "#{k}", v if v > 0
      end
      
      #this is a bad hack ... I can't seem to remove the title
      complete_url = pc.to_url.to_s.gsub("=Pie+Chart", "")
      return complete_url
    end
  rescue
  end
  
end
