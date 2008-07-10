module PollsHelper
  
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
    options[:width] ||= 250
    options[:height] ||= 100
    options[:colors] = %w(0DB2AC F5DD7E FC8D4D FC694D FABA32 704948 968144 C08FBC ADD97E)
    dt = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-."
    options[:divisor] ||= 1
    
    while (data.map { |k,v| v }.max / options[:divisor] >= 4096) do
      options[:divisor] *= 10
    end
    
    opts = {
      :cht => "p",
      :chd => "e:#{data.map{|k,v|v=v/options[:divisor];dt[v/64..v/64]+dt[v%64..v%64]}}",
      :chl => "#{data.map { |k,v| CGI::escape(k + " (#{v})")}.join('|')}",
      :chs => "#{options[:width]}x#{options[:height]}",
      :chco => options[:colors].slice(0, data.length).join(',')
    }
    
    image_tag("http://chart.apis.google.com/chart?#{opts.map{|k,v|"#{k}=#{v}"}.join('&')}")
  rescue
  end
end
