# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
    
  def render_menus 
    @menus = [
      ["Ideas",           "/ideas"                             ],
      ["Products",        products_path,                       ],
      ["Releases",        list_releases_path                   ],
      ["Forums",          forums_path                          ],
      ["Lookup Codes",    lookup_codes_path,    ["sysadmin"]   ],
      ["Users",           "/users",             ["sysadmin", "allocmgr"] ],
      ["Enterprises",     enterprises_path,     ["sysadmin", "allocmgr"] ],
      ["Allocations",     allocations_path,                    ],
      ["Votes",           votes_path                           ],
      ["Announcements",   announcements_path ,  ["sysadmin", "prodmgr"]  ],
      ["Polls",           polls_path ,          ["prodmgr"]  ],
    ]
    output = ""
    for menu in @menus
      accessible = menu[2].nil?   # no restrictions specified
      if !accessible then         # otherwise you'll need to loop through
        for priviledge in menu[2] # and explicitly see if user has access
          restrict_to priviledge do 
            accessible = true
          end
        end
      end
      
      if accessible then          # should the user see the menu?
        clazz = nil
        clazz = "current" if menu_selected menu[1]
        output += "<li>#{link_to(menu[0], menu[1], :class => clazz)}</li>"
      end
    end
    output
  end
  
  @@theme_path = nil
  
  def theme_image_tag image_path, params=nil
    assign_theme_path
    image_tag("#{@@theme_path}/images/#{image_path}", params)
  end  
  
  def theme_stylesheet_link_tag stylesheet
    assign_theme_path
    stylesheet_link_tag("#{@@theme_path}/stylesheets/#{stylesheet}")
  end  
  
  
  
  def set_focus_to_id_in_list_form(id)
    #  javascript_tag("$('#{id}').focus()");
    #    Reverted back to this manner...works if you put it immediately following the form
    #    RBS 1/15/2008
    <<-END
        <script language="javascript">
            <!--
                    document.getElementById("#{id}").focus()
            //-->
        </script>
    END
  end
  
   
  def markaby(&block)
    Markaby::Builder.new({}, self, &block)
  end
  
  # Got this code from 
  # http://blog.wolfman.com/articles/2006/10/29/setting-the-focus-in-a-form
  def set_focus_to_id(id)
    #  javascript_tag("$('#{id}').focus()");
    #    RES: FIXES IE onfocus BUG (i think  the browser looses it's css styles when done the other way
    #    -- nevertheless, though it's now fixed, this is considered "obtrusive javascript", 
    #    it would be better to implement this "unobstrusively" -- something to come back to later.
    #    Reverted back to the above way RBS 1/15/2008
    "onload=\"document.getElementById('#{id}').focus();\""    
  end
  
  # Format a date and adjust the timezone for the user's timezone
  def om_date_time(the_date)
    h format_date_time(current_user.user_time(the_date)) unless the_date.nil?
  end
  
  # If value is null, return null_value, else return null
  def nvl value, null_value
    return null_value if value.nil? or (value.class == String and value.empty?)
    value
  end
  
  def user_display_name user
    full = prodmgr? or sysadmin? or allocmgr?
    user.display_name full
  end
  
  # Required to support hard line breaks
  # See http://wiki.rubyonrails.org/rails/pages/RedCloth for a discussion
  def textilize(text) 
    RedCloth.new(text, [:hard_breaks]).to_html
  end
  
  
  def bold_text(text, bold)
    return text unless bold
    "<strong>#{text}</strong>"
  end

  
  private
  
  def assign_theme_path    
    @@theme_path ||= "/themes/#{APP_CONFIG['app_theme']}"
  end
  
  def format_date_time(the_date)
    the_date.strftime("%b %d, %Y %I:%M%p") unless the_date.nil?
  end
  
  def format_date(the_date)
    the_date.strftime("%b %d, %Y") unless the_date.nil?
  end
  
  def menu_selected path
    path = path.from(1) if path.index('/') == 0
    path == params['controller']
  end
end
