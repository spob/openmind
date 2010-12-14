# Methods added to this helper will be available to all templates in the application
require 'redcloth'

module ApplicationHelper
  include TagsHelper  
  
  def render_menus 
    @no_menu_screens = [
    ["account", "login"],
    ["users", "lost_password"],
    ]
    
    @menus = [
    # Menu Label       # controller url       # role restrictions   # other
    # controllers e.g., aliases
    ["Ideas",           "/ideas"                             ],
    ["Forums & KnowledgeBase",          forums_path,          [],                  [ "topics", "comments" ] ],
    ["Roadmap",        list_releases_path,   [],                    [ "products", "releases" ]   ],
    ["Users",           "/users",             ["sysadmin", "allocmgr"], ["groups", "user_requests", "user_logons"] ],
    ["Enterprises",     enterprises_path,     ["sysadmin", "allocmgr"] ],
    ["Allocations",     allocations_path,                    ],
    ["Votes",           votes_path                           ],
    ["Announcements",   announcements_path ,  ["sysadmin", "prodmgr"]  ],
    ["Attachments",     attachments_path,     ["sysadmin", "prodmgr", "mediator"]  ],
    ["Polls",           polls_path,           ],
    ["Portal",          portal_index_path,          ],
    ["Projects",        projects_path ,  ["developer"]  ],
    ["Admin",           periodic_jobs_path,    ["sysadmin"],  ["lookup_codes", "link_sets"] ],
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
          if current_user.roles.collect(&:title).include? priviledge
            accessible = true
            break;
          end
        end
      end
      
      # Special case for partner portal
    #  puts menu[0]
      accessible = false if accessible && menu[0] == "Portal" && (!logged_in? || !current_user.try(:can_view_portal?))
      if accessible then          # should the user see the menu?
        clazz = nil
        clazz = "current" if menu_selected menu[1]
        if menu_selected(comments_path) && params[:type] == "Idea"
          clazz = "current" if menu[0] == "Ideas"
        else
          if clazz.nil? && !menu[3].nil? # not selected...but check it's aliases
            for controller_alias in menu[3]
              clazz = "current" if menu_selected controller_alias
            end
          end
        end
        # don't have a better way than to hard code the special case for idea comments
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
  
  def theme_stylesheet_link_tag *stylesheets
    assign_theme_path
    sheets = []
    for sheet in stylesheets
      sheets << "#{@@theme_path}/stylesheets/#{sheet}"
    end
    stylesheet_link_tag(sheets, :cache => "..#{@@theme_path}/cache/#{stylesheets.first}", :media => 'all')
  end  
  
  def title(page_title)  
    content_for(:title) { page_title }  
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
  
  
  def show_links link_set
    return if link_set.nil?
    # reverse the array since we'll push and pop the entries
    links = link_set.links.reverse
    markaby do
      until links.empty? do
        link = links.pop
        if link.heading?
          p link.name
        else
          links.push link # not a heading...put it back on the array because we'll pop it back off shortly
          div.unorderListNavContainer do
            ul.navlist2 do
              while true
                link = links.pop
                if link.nil? 
                  break;
                else if link.heading?
                  links.push link   # a heading...put it back on and process it above
                  break
                else
                  li do
                    link_to(link.name, link.url)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

# Got this code from
# http://blog.wolfman.com/articles/2006/10/29/setting-the-focus-in-a-form
def set_focus_to_id(id, othertxt=nil)
  #  javascript_tag("$('#{id}').focus()");
  #    RES: FIXES IE onfocus BUG (i think  the browser looses it's css styles when done the other way
  #    -- nevertheless, though it's now fixed, this is considered "obtrusive javascript",
  #    it would be better to implement this "unobstrusively" -- something to come back to later.
  #    Reverted back to the above way RBS 1/15/2008
    "onload=\"document.getElementById('#{id}').focus();#{othertxt}\""    
end

def announcement_link announcement
  text = truncate(announcement.headline, :length => 25)
  if current_user == :false or announcement.unread?(current_user)
    text = "<b>#{truncate(announcement.headline, :length => 21)}</b>"
  end
  link_to text, "#{announcements_path}##{announcement.id}"
end  

# Format a date and adjust the timezone for the user's timezone
def om_date_time(the_date)
  h format_date_time(the_date) unless the_date.nil?
end

# Format a date 
def om_date(the_date)
  h format_date(the_date) unless the_date.nil?
end

# If value is null, return null_value, else return null
def nvl value, null_value
  return null_value if value.nil? or (value.class == String and value.empty?)
  value
end

def user_display_name user
  full = (prodmgr? or sysadmin? or allocmgr? or current_user.mediator?) unless current_user == :false
  user.display_name full unless user.nil?
end

# Required to support hard line breaks See
# http://wiki.rubyonrails.org/rails/pages/RedCloth for a discussion
def textilize(text) 
  RedCloth.new(text, [:hard_breaks]).to_html
end


def bold_text(text, bold)
  return text unless bold
    "<strong>#{text}</strong>"
end

def strike_text(text, strike)
  return text unless strike
    "<strike>#{text}</strike>"
end

def show_comment_edit_links
  params["action"] != "new"
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
