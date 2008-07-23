class Graph
  require 'md5'
  attr_accessor :data_sets, :data
  def initialize

    ###########removed between 1.9.3 and 1.9.6
    #@title_size		 = 30
    #@line_default = "&line=3,#87421F" + "& \n"
    
    ########### same since 1.9.3
    @data  				 = [] 
    @x_labels			 = [] 
    @y_min				 = 0
    @y_max				 = 20
    @title				 = ""
    @title_style   = ""
    @x_tick_size	 = -1
    @y2_max				 = ''
    @y2_min				 = ''
    # GRID styles
    @y_axis_color	= ''
    @x_axis_color = ''
    @x_grid_color  = '' 
    @y_grid_color = ""
    @x_axis_3d    = ''
    @x_axis_steps	= 1
    @y2_axis_color = ''
    
    # AXIS LABEL styles
    @x_label_style						 = ''
    @y_label_style 						 = ''
    @y_label_style_right			 = ''
    
    # AXIS LEGEND styles
    @x_legend				= ''
    @y_legend				= ''
    @y_legend_right = ''
    
    @lines				= {}
    
    @bg_color	= ''
    @bg_image = ''

    @inner_bg_color	  = ''
    @inner_bg_color_2 = ''
    @inner_bg_angle   = ''
    
    # PIE chart
    @pie        = ''
    @pie_values = ''
    @pie_colors = ''
    @pie_labels = ''
    @pie_links  = ''

    @tool_tip   = ''

    @y2_lines			= []
    
    @y_label_steps = 5
    
    ########## new between 1.9.3 and 1.9.6
    @data_sets     = []
    @links         = []
    @width         = 250
    @height        = 200
    @base          = 'js/'
    @x_min         = 0
    @x_max         = 20
    @y_steps       = ''
    @occurence     = 0
    @x_offset      = ''
    @x_legend_size = 20
    @x_legend_color = '#000000'
    @line_default  = {'type' => 'line', 'values' => '3,#87421F'}
    @js_line_default = 'so.addVariable("line","3,#87421F")'
    
    @y_format = ''
    @num_decimals = ''
    @is_fixed_num_decimals_forced = ''
    @is_decimal_separator_comma = ''
    @is_thousand_separator_disabled = ''

    ##### OTHER THINGS
    @unique_id   = ""
    @js_path     = "/javascripts/"
    @swf_path    = "/"
    @output_type = ""
  end

  # new methods between 1.9.3 and 1.9.6
  def set_unique_id()
    md5 = Digest::MD5.new << Time.now.to_s << String(Time.now.usec) << String(rand(0)) << String($$) << "open_flash_chart"
    @unique_id = md5.hexdigest 
  end

  def get_unique_id()
    @unique_id
  end

  def set_js_path(path)
    @js_path = path
  end

  def set_swf_path(path)
    @swf_path = path
  end

  def set_output_type(type)
    @output_type = type
  end

  def next_line
    line_num = ''
    line_num = '_' + (@lines.size + 1).to_s if @lines.size > 0
    line_num
  end
  
  def self.esc(text)
    tmp = text.to_s.gsub(",","#comma#")
    CGI::escape(tmp)
  end

  def format_output(function, values)
    if @output_type == 'js'
    	return "so.addVariable('#{function}','#{values}');"
    else
    	return "&#{function}=#{values}&"
    end
  end

  %w(width height base y_format num_decimals).each do |method| 
    define_method("set_#{method}") do |a|
    	self.instance_variable_set("@#{method}", a)
    end
  end

  %w(x_offset is_fixed_num_decimals_forced is_decimal_separator_comma is_thousand_separator_disabled).each do |method|
    define_method("set_#{method}") do |a|
    	self.instance_variable_set("@#{method}", a ? 'true':'false')
    end
  end
  

  #####################################

  %w(data links).each do |method|
    define_method("set_#{method}") do |a|
      @data  << a.join(',') if method == 'data'
      @links << a.join(',') if method == 'links'
    end
  end
  
  %w(tool_tip).each do |method|
    define_method("set_#{method}") do |a|
    	self.instance_variable_set("@#{method}", Graph.esc(a))
    end
  end

  # create the set methods for these instance variables in a loop since they are all the same
  %w(bg_color x_max x_min y_max y_min).each do |method|
    define_method("set_#{method}") do |a|
    	self.instance_variable_set("@#{method}", a)
    end
  end

  def set_x_labels(a)
    @x_labels = a
  end
  
  def set_y_label_steps(val)
    @y_steps = val
  end  	
  
  %w(x_tick_size x_axis_steps x_axis_3d).each do |method|
    define_method("set_#{method}") do |a|
    	self.instance_variable_set("@#{method}", a) if a > 0
    end
  end

  def set_x_label_style(size, color='', orientation=0, step=-1, grid_color='')
    @x_label_style  = size.to_s
    @x_label_style += ",#{color}" 			if color.size > 0
    @x_label_style += ",#{orientation}" if orientation > -1
    @x_label_style += ",#{step}" 				if step > 0
    @x_label_style += ",#{grid_color}"  if grid_color.size > 0
  end

  def set_bg_image(url, x='center', y='center')
    @bg_image 	= url
    @bg_image_x = x
    @bg_image_y = y
  end

  def attach_to_y_right_axis(data_number)
    @y2_lines << data_number
  end

  def set_inner_background(col, col2='', angle=-1)
    @inner_bg_color   = col
    @inner_bg_color_2 = col2  if col2.size > 0
    @inner_bg_angle   = angle if angle != -1
  end

  %w(y_label_style y_right_label_style).each do |method|
    define_method("set_#{method}") do |size, color|
    	temp  = size.to_s
    	temp += ",#{color}" if color.size > 0
      if method == "y_right_label_style"
    	  self.instance_variable_set("@y_label_style_right", temp)
      else
    	  self.instance_variable_set("@#{method}", temp)
      end
    end
  end

  %w(max min).each do |m|
   	define_method("set_y_right_#{m}") do |x|
    	temp = "&y2_#{m}=#{x}& \n"
    	self.instance_variable_set("@y2_#{m}", temp)
    end
  end

  def set_title(title, style='')
    @title       = Graph.esc(title)
    @title_style = style  if style.size > 0
  end

  def title(title, style='')
    set_title(title, style)
  end

  def set_x_legend(text, size=-1, color='') 
    # next three lines will only be needed if defining y_rigth_legend
    method  	= "x_legend"
    self.instance_variable_set("@#{method}", Graph.esc(text))
    self.instance_variable_set("@#{method}" + "_size", size) if size > 0
    self.instance_variable_set("@#{method}" + "_color", color) if color.size > 0
  end
  
  %w(y_legend y_legend_right).each do |method|
   	define_method("set_" + method) do |text, *optional| 
      size,color = *optional
    	size  ||= -1
    	color ||= ''
    	# next three lines will only be needed if defining y_rigth_legend
    	method  = "y_legend_right" if method =~ /right/
    	label		= method
    	label		= "y2_legend" if method =~ /right/
    	temp = text
    	temp += ",#{size}"  if size > 0
    	temp += ",#{color}" if !color.blank? 
      self.instance_variable_set("@#{method}", temp)
    end
  end

  def line(width, color='', text='', size=-1, circles=-1)
    type = 'line' + next_line
    description = ''

    if width > 0
    	description += "#{width}"
    	description += ",#{color}"
    end

    if text.size > 0
    	description += ",#{text}"
    	description += ",#{size}"
    end

    if circles > 0
    	description += ",#{circles}" 
    end
    @lines[type] = description
  end

  %w(line_dot line_hollow).each do |method|
    define_method(method) do |width, dot_size, color, *optional|
      text,font_size = *optional
    	text ||= ''
    	font_size ||= ''

    	type = method + next_line
    	description  = "#{width},#{color},#{text}"
    	description += ",#{font_size},#{dot_size}"
    	
    	@lines[type] = description	
    end
  end

  def area_hollow(width, dot_size, color, alpha, text='', font_size='', fill_color='')
    type = "area_hollow" + next_line
    description = "#{width},#{dot_size},#{color},#{alpha}"
    
    description += ",#{text},#{font_size}" if text.size > 0
    description += ",#{fill_color}" if fill_color.size > 0

    @lines[type] = description
  end


  %w(bar bar_3d bar_fade).each do |method|
    define_method(method) do |alpha, *optional|
      color,text,size = *optional
    	color ||= ''
    	text  ||= ''
      size  ||= -1
    	type = method + next_line

    	description = "#{alpha},#{color},#{text},#{size}"

    	@lines[type] = description
    end
  end

  %w(bar_glass bar_filled).each do |method|
    define_method(method) do |alpha, color, color_outline, *optional|
      text,size = *optional
    	text ||= ""
    	size ||= -1
    	method = "filled_bar" if method == "bar_filled"

    	type = method + next_line

    	description = "#{alpha},#{color},#{color_outline},#{text},#{size}"

    	@lines[type] = description
    end
  end

  def bar_sketch(alpha, offset, color, color_outline, text='', size=-1)
    	type = "bar_sketch" + next_line

    	description = "#{alpha},#{offset},#{color},#{color_outline},#{text},#{size}"

    	@lines[type] = description
  end

  %w(candle hlc).each do |method|
    define_method(method) do |data, alpha, line_width, color, *optional|
      text,size = *optional 
    	text ||= ""
    	size ||= -1

    	type = method + next_line

    	description = "#{alpha},#{line_width},#{color},#{text},#{size}"

    	@lines[type] = description
    	@data << data.collect{|d| d.toString}.join(",")
    end
  end

  def scatter(data, line_width, color, text='',size=-1)
    type = "scatter" + next_line

    description = "#{line_width},#{color},#{text},#{size}"
    @lines[type] = description
    
    @data << data.collect{|d| d.toString}.join(",")
  end
  

  %w(x y).each do |method|
    define_method("set_" + method + "_axis_color") do |axis, *optional|
      grid = *optional
    	grid ||= ''
      self.instance_variable_set("@#{method}_axis_color", axis)
      self.instance_variable_set("@#{method}_grid_color", grid)
    end
  end

  def y_right_axis_color(color)
    @y2_axis_color = color
  end

  def pie(alpha, line_color, style, gradient = true, border_size = false)
    @pie = "#{alpha},#{line_color},#{style}"
    if !gradient
    	@pie += ",#{!gradient}"
    end
    if border_size
    	@pie += "," if gradient === false
    	@pie += ",#{border_size}"
    end
  end

  def pie_values(values, labels = [], links = [])
    @pie_values = values.join(',')
    @pie_labels = labels.join(',')
    @pie_links  = links.join(",")
  end

  def pie_slice_colors(colors)
    @pie_colors = colors.join(",")
  end

  def render
    temp  = []
    
    if @output_type == 'js'
    	set_unique_id
    	temp << '<div id="my_chart' + "#{@unique_id}" + '"></div>'
    	temp << '<script type="text/javascript" src="' + "#{@js_path}/swfobject.js" + '"></script>'
    	temp << '<script type="text/javascript">'
    	temp << 'var so = new SWFObject("' + @swf_path + 'open-flash-chart.swf", "ofc", "' + @width.to_s + '", "' + @height.to_s + '", "9", "#FFFFFF");'
    	temp << 'so.addVariable("variables","true");'
    end

    {"title" 					=> [@title, @title_style],
     "x_legend"				=> [@x_legend, @x_legend_size, @x_legend_color],
     "x_label_style"  => [@x_label_style],
     "x_ticks"				=> [@x_tick_size],
     "x_axis_steps"   => [@x_axis_steps],
     "x_axis_3d"      => [@x_axis_3d],
     "y_legend"       => [@y_legend],
     "y2_legend"      => [@y_legend_right],
     "y_min"          => [@y_min],
     "y_label_style"  => [@y_label_style],
     "y2_min"         => [@y2_min],
     "y2_max"         => [@y2_max],
     "bg_colour" 			=> [@bg_color],
     "bg_image"       => [@bg_image],
     "bg_image_x"     => [@bg_image_x],
     "bg_image_y"     => [@bg_image_y],
     "x_axis_colour"  => [@x_axis_color],
     "x_grid_colour"  => [@x_grid_color],
     "y_axis_colour"  => [@y_axis_color],
     "y_grid_colour"  => [@y_grid_color],
     "y2_axis_colour" => [@y2_axis_color],
     "x_offset"       => [@x_offset],
     "inner_background" => [@inner_bg_color, @inner_bg_color_2, @inner_bg_angle],
     "tool_tip"				=> [@tool_tip],
     "y_format"       => [@y_format],
     "num_decimals"   => [@num_decimals],
     "is_fixed_num_decimals_forced"   => [@is_fixed_num_decimals_forced],
     "is_decimal_separator_comma"   => [@is_decimal_separator_comma],
     "is_thousand_separator_disabled"   => [@is_thousand_separator_disabled]
    }.each do |k,v|
    	next if v[0].nil?
    	next if (v[0].class == String ? v[0].size <= 0 : v[0] < 0)
    	temp << format_output(k, v.compact.join(","))
    end

    temp << format_output("y_ticks", "5,10,#{@y_steps}")

    if @lines.size == 0 and @data_sets.size == 0
    	temp << format_output(@line_default['type'], @line_default['values'])
    else
    	@lines.each do |type,description|
    		temp << format_output(type, description)
    	end
    end
    
    num = 1
    @data.each do |data|
    	if num == 1
    		temp << format_output('values', data)
    	else
    		temp << format_output("values_#{num}", data)
    	end
    	num += 1
    end
    
    num = 1
    @links.each do |link|
    	if num == 1
    		temp << format_output('links', link)
    	else
    		temp << format_output("links_#{num}", link)
    	end
    	num += 1
    end

    if @y2_lines.size > 0
    	temp << format_output('y2_lines', @y2_lines.join(','))
    	temp << format_output('show_y2', 'true')
    end

    if @x_labels.size > 0	
    	temp << format_output('x_labels', @x_labels.join(","))
    else
    	temp << format_output('x_min', @x_min) if @x_min.size > 0
    	temp << format_output('x_max', @x_max) if @x_max.size > 0
    end

    temp << format_output('y_min', @y_min)
    temp << format_output('y_max', @y_max)

    if @pie.size > 0
    	temp << format_output('pie', @pie)	
    	temp << format_output('values', @pie_values)	
    	temp << format_output('pie_labels', @pie_labels)	
    	temp << format_output('colours', @pie_colors)	
    	temp << format_output('links', @pie_links)	
    end

    count = 1
    @data_sets.each do |set|
    	temp << set.toString(@output_type, count > 1 ? "_#{count}" : '')
      count += 1
    end

    if @output_type == "js"
    	temp << 'so.write("my_chart' + @unique_id + '");'
    	temp << '</script>'
    end	

    return temp.join("\r\n")
  end
end

class Line
  attr_accessor :line_width, :color, :_key, :key, :key_size, :data, :tips, :var
  def initialize(line_width, color)
    @var   = 'line'
    @line_width = line_width
    @color = color
    @data  = []
    @links = []
    @tips  = []
    @_key  = false
  end

  def key(key, size)
    @_key = true
    @key  = Graph.esc(key)
    @key_size = size
  end

  def add(data)
    @data << (data.nil? ? 'null' : data)
  end 

  def add_link(data, link)
    add(data)
    @links << Graph.esc(link)
  end

  def add_data_tip(data, tip)
    add(data)
    @tips << Graph.esc(tip)
  end

  def add_data_link_tip(data, link, tip)
    add_link(data, link)
    @tips << Graph.esc(tip)
  end

  def _get_variable_list
    values = []
    values << @line_width
    values << @color
    if @_key
      values << @key
      values << @key_size
    end
    return values
  end

  def toString(output_type, set_num)
    values = _get_variable_list.join(",")
    tmp = []

    if output_type == 'js'
      tmp << 'so.addVariable("' + @var + set_num.to_s + '","' + values + '");'
      tmp << 'so.addVariable("values' + set_num.to_s + '","' + @data.join(",") + '");'
      if !@links.empty?
        tmp << 'so.addVariable("links' + set_num.to_s + '","' + @links.join(",") + '");'
      end
      if !@tips.empty?
        tmp << 'so.addVariable("tool_tips_set' + set_num.to_s + '","' + @tips.join(",") + '");'
      end
    else
      tmp << '&' + @var + set_num.to_s + '=' + values + '&'
      tmp << '&values' + set_num.to_s + '=' + @data.join(",") + '&'
      if !@links.empty?
        tmp << '&links' + set_num.to_s + '=' + @links.join(",") + '&'
      end
      if !@tips.empty?
        tmp << '&tool_tips_set' + set_num.to_s + '=' + @tips.join(",") + '&'
      end
    end
    return tmp.join("\r\n")
  end
end

class LineHollow < Line
  attr_accessor :dot_size, :var
  def initialize(line_width, dot_size, color)
    super(line_width, color)
    @var = 'line_hollow'
    @dot_size = dot_size
  end

  def _get_variable_list
    values = []
    values << @line_width
    values << @color
    if @_key
      values << @key
      values << @key_size
    else
      values << ''
      values << ''
    end
    values << @dot_size
    return values
  end
end

class LineDot < LineHollow
  def initialize(line_width, dot_size, color)
    super(line_width, dot_size, color)
    @var = 'line_dot'
  end
end

class Bar
  attr_accessor :color, :alpha, :data, :links, :_key, :key, :key_size, :tips, :var

  def initialize(alpha, color)
    @var   = 'bar'
    @alpha = alpha
    @color = color
    @data  = []
    @links = []
    @tips  = []
    @_key  = false 
  end

  def key(key, size)
    @_key = true
    @key  = Graph.esc(key)
    @key_size = size
  end

  def add(data)
    @data << (data.nil? ? 'null' : data)
  end  

  def add_link(data, link)
    add(data)
    @links << Graph.esc(link)
  end

  def add_data_tip(data, tip)
    add(data)
    @tips << Graph.esc(tip)
  end

  def _get_variable_list
    values = []
    values << @alpha
    values << @color

    if @_key
    	values << @key
    	values << @key_size
    end

    return values
  end

  def toString(output_type, set_num)
    values = _get_variable_list.join(",")

    temp = []

    if output_type == 'js'
    	temp << 'so.addVariable("' + @var + set_num.to_s + '","' + values + '");'
    	temp << 'so.addVariable("values' + set_num.to_s + '","' + @data.join(",") + '");'
    	if @links.size > 0
    		temp << 'so.addVariable("links' + set_num.to_s + '","' + @links.join(",") + '");'
    	end
    	if @tips.size > 0
    		temp << 'so.addVariable("tool_tips_set' + set_num.to_s + '","' + @tips.join(",") + '");'
    	end
    else
    	temp << '&' + @var + set_num.to_s + '=' + values + '&'
    	temp << '&values' + set_num.to_s + '=' + @data.join(",") + '&'
    	if @links.size > 0
    		temp << '&links' + set_num.to_s + '=' + @links.join(",") + '&'
    	end
    	if @tips.size > 0
    		temp << '&tool_tips_set' + set_num.to_s + '=' + @tips.join(",") + '&'
    	end
    end

    return temp.join("\r\n")
  end
end

class Bar3d < Bar
  def initialize(alpha, color)
    super(alpha,color)
    @var = 'bar_3d'
  end
end

class BarFade < Bar
  def initialize(alpha, color)
    super(alpha, color)
    @var = 'bar_fade'
  end  
end

class BarOutline < Bar
  def initialize(alpha, color, outline_color)
    super(alpha, color)
    @var = 'filled_bar'
    @outline_color = outline_color
  end

  def _get_variable_list
    values = []
    values << @alpha
    values << @color
    values << @outline_color

    if @_key
    	values << @key
    	values << @key_size
    end

    return values
  end
end

class BarGlass < BarOutline
  def initialize(alpha, color, outline_color)
    super(alpha, color, outline_color)
    @var = 'bar_glass'
  end
end

class BarSketch < BarOutline
  def initialize(alpha, offset, color, outline_color)
    super(alpha, color, outline_color)
    @var = 'bar_sketch'
    @offset = offset
  end  

  def _get_variable_list
    values = []
    values << @alpha
    values << @offset
    values << @color
    values << @outline_color

    if @_key
    	values << @key
    	values << @key_size
    end
    
    return values
  end
end

class Candle
  def initialize(high, open, close, low)
    @out = []
    @out << high
    @out << open
    @out << close
    @out << low
  end
  
  def toString
    return '[' + @out.join(",") + ']'
  end
end

class Hlc
  def initialize(high, low, close)
    @out = [high, low, close]
  end

  def toString
    return '[' + @out.join(",") + ']'
  end
end

class Point
  def initialize(x,y,size_px)
    @out = [x,y,size_px]
  end

  def toString
    return '[' + @out.join(',') + ']'
  end
end

$open_flash_chart_seqno = nil

def _ofc(width, height, url, use_swfobject, base="/", set_wmode_transparent=false)
  url = CGI::escape(url)
  out = []

  protocol = 'http'
  if request.env["HTTPS"] == 'on'
    protocol = 'https'
  end

  obj_id = 'chart'
  div_name = 'flashcontent'

  if !$open_flash_chart_seqno
    $open_flash_chart_seqno = 1
    out << '<script type="text/javascript" src="' + base + 'javascripts/swfobject.js"></script>'
  else
    $open_flash_chart_seqno += 1
    obj_id   += "_#{$open_flash_chart_seqno}"
    div_name += "_#{$open_flash_chart_seqno}"
  end

  if use_swfobject
    out << '<div id="' + div_name + '"></div>'
    out << '<script type="text/javascript">'
    out << 'var so = new SWFObject("' + base + 'open-flash-chart.swf", "' + obj_id + '","' + width.to_s + '","' + height.to_s + '", "9", "#FFFFFF");'
    out << 'so.addVariable("data", "' + url + '");'
		out << 'so.addParam("wmode", "transparent");' if set_wmode_transparent
    out << 'so.addParam("allowScriptAccess", "sameDomain");'
    out << 'so.write("' + div_name + '");'
    out << '</script>'
    out << '<noscript>'
  end

  out << '<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="' + protocol + '://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0" '
  out << 'width="' + width.to_s + '" height="' + height.to_s + '" id="ie_' + obj_id + '" align="middle">'
  out << '<param name="allowScriptAccess" value="sameDomain" />'
  out << '<param name="movie" value="' + base + 'open-flash-chart.swf?' + width.to_s + '&height=' + height.to_s + '&data=' + url + '" />'
  out << '<param name="quality" value="high" />'
  out << '<param name="bgcolor" value="#FFFFFF" />'
	out << '<param name="wmode" value="transparent" />' if set_wmode_transparent
  out << '<embed src="' + base + 'open-flash-chart.swf?data=' + url + '" quality="high" bgcolor="#FFFFFF" width="' + width.to_s + '" height="' + height.to_s + '" name="' + obj_id + '" align="middle" allowScriptAccess="sameDomain" '
  out << 'type="application/x-shockwave-flash" pluginpage="' + protocol + '://ww.macromedia.com/go/getflashplayer" id="' + obj_id + '"/>'
  out << '</object>'

  if use_swfobject
    out << '</noscript>'
  end  

  return out.join("\n")
end

def open_flash_chart_object_str(width, height, url, use_swfobject=true, base='/', set_wmode_transparent=false)
  return _ofc(width, height, url, use_swfobject, base, set_wmode_transparent)  
end

def open_flash_chart_object(width, height, url, use_swfobject=true, base='/', set_wmode_transparent=false)
  return _ofc(width, height, url, use_swfobject, base, set_wmode_transparent)
end
