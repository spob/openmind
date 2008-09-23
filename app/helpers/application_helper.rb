# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper  
    
  def render_menus 
    @no_menu_screens = [
      ["account", "login"],
      ["users", "lost_password"],
    ]
      
    @menus = [
      # Menu Label       # controller url       # role restrictions   # other controllers e.g., aliases
      ["Ideas",           "/ideas"                             ],
      ["Products",        products_path,                       ],
      ["Releases",        list_releases_path,   [],                  [ "releases" ] ],
      ["Forums",          forums_path,          [],                  [ "topics" ] ],
      ["Lookup Codes",    lookup_codes_path,    ["sysadmin"]   ],
      ["Jobs",            periodic_jobs_path,    ["sysadmin"]   ],
      ["Users",           "/users",             ["sysadmin", "allocmgr"], ["groups", "user_requests", "user_logons"] ],
      ["Enterprises",     enterprises_path,     ["sysadmin", "allocmgr"] ],
      ["Allocations",     allocations_path,                    ],
      ["Votes",           votes_path                           ],
      ["Announcements",   announcements_path ,  ["sysadmin", "prodmgr"]  ],
      ["Polls",           polls_path ,          ],
    ]
    
    #    puts "controller #{params["controller"]} action: #{params["action"]}"
    # Don't display the menu if the user is on one of these screens
    for screen in @no_menu_screens
      if screen[0] == params["controller"] and screen[1] == params["action"]
        return
      end
    end
    
    output = ""
    for menu in @menus
      accessible = (menu[2].nil? or menu[2].empty?)  # no restrictions specified
      if !accessible and logged_in? then         # otherwise you'll need to loop through
        for priviledge in menu[2] # and explicitly see if user has access
          restrict_to priviledge do 
            accessible = true
          end
        end
      end
      
      if accessible then          # should the user see the menu?
        clazz = nil
        clazz = "current" if menu_selected menu[1]
        if clazz.nil? and !menu[3].nil? # not selected...but check it's aliases
          for controller_alias in menu[3]
            clazz = "current" if menu_selected controller_alias
          end
        end
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
    h format_date_time(the_date) unless the_date.nil?
  end
  
  # If value is null, return null_value, else return null
  def nvl value, null_value
    return null_value if value.nil? or (value.class == String and value.empty?)
    value
  end
  
  def user_display_name user
    full = prodmgr? or sysadmin? or allocmgr? unless current_user == :false
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
    strip_leading_slash(path) == params['controller']
  end
  
  def strip_leading_slash path
    path = path.from(1) if path.index('/') == 0
    path
  end
end
