module IdeasHelper
  
  
  @@view_types = [ 
    ["Newest", "all"],
    ["Mine", "my_ideas"],
    ["Unread", "unread"],
    ["With unread comments", "unread_comments"],
    ["I'm watching", "watched"],
    ["I have voted on", "voted_ideas"],
    ["I have commented on", "commented_ideas"],
    ["Most popular", "most_votes"],
    ["Most viewed", "most_views"],
  ]
  
  def calc_titles_for_lookup
    titles = Idea.find(:all, :select => 'title', :order => 'title')
    titles_string =  "["
    titles.each_with_index do |idea,index|
      titles_string += "," unless index == 0
      titles_string += "'"
      titles_string += idea.title.gsub(/[']/, '\\\\\'')
      titles_string += "'"
    end
    titles_string +=  "]"
    titles_string
  end
  
  def show_filter_tabs
    markaby do
      div.filtermenu! do
        div.menutitle "Filter Ideas By:"
        ul do
          for view_type in @@view_types
            clazz = ""
            clazz = "selected" if session[:idea_view_type] == view_type[1]
            li do
              #              link_to(view_type[0], 
              #                options = {:action => :index, :view_type => view_type[1]}, 
              #                html_options = {:class=> clazz})
              link_to_remote(view_type[0], 
                { :url => {:action => :index, :view_type => view_type[1]}}, 
                {:class=> clazz})
            end 
          end
        end
      end
    end
  end

  def can_create_idea?
    voter? or prodmgr?
  end
  
  def merged_to_idea idea
    link_to sanitize(idea.merged_to_idea.user_friendly_idea_name), :action => 'show', 
      :id => idea.merged_to_idea.id unless idea.merged_to_idea.nil?
  end

  def show_toggle_votes_link idea
    #    link = pluralize(@idea.votes.size, 'vote')       
    if !idea.votes.empty?
      link  = link_to_remote "Votes", 
        :url=> {:controller => :ideas, :action=> 'select_votes', :id => @idea }
      link  = "<li #{tab_class "VOTES"}>#{link}</li>"
    end 
    link
  end
  
  def can_edit_comment? comment
    comment.can_edit?(current_user, prodmgr? || sysadmin?)
  end

  #  link_to_remote pluralize(@idea.comments.size, 'comment'), :url => { :action => 'toggle_comments' }
  
  def show_toggle_comments_link idea
    #    link = pluralize(@idea.comments.size, 'comment')
    if !idea.comments.empty?
      link  = link_to_remote "Comments", 
        :url => { :controller => :ideas, :action => 'select_comments', :id => idea.id }
      link  = "<li #{tab_class "COMMENTS"}>#{link}</li>"
    end 
    link
  end

  #  def show_comments_tab idea
  #    if !idea.comments.empty?
  #      link  = link_to_remote "Comments", :url => { :action => 'toggle_comments' }
  #    end 
  #    link
  #  end

  
  def status(idea)
    if (!idea.merged_to_idea.nil?)
      return "Merged"
    elsif (!idea.release.nil?)
      return "Scheduled"
    end
    "Open"
  end
  
  def allow_schedule_to_release?
    prodmgr?
  end
  
  def all_products_with_all
    products = [["All Products", 0]]
    for product in Product.all_products
      name = product.name
      name = "#{product.name} (inactive)" if !product.active
      products << [name, product.id]
    end
    products
  end
  
  def all_authors_with_all
    names = []
    for user in Idea.authors
      name = user_display_name(user)
      name = "#{user_display_name(user)} (inactive)" if !user.active
      names << [name, user.id]
    end
    names.sort!{|x,y| x[0].upcase <=> y[0].upcase }
    names.unshift [["All Authors", nil]]
    names
  end
  
  def all_unmerged_ideas(exclude_id)
    ideas = [["", nil]]
    for idea in Idea.find(:all, :conditions => "merged_to_idea_id is null", :order => "created_at asc")
      ideas << [idea.user_friendly_idea_name, idea.id] unless idea.id == exclude_id
    end
    ideas
  end
  
  def comment_link
    if !@idea.comments.empty?
      link = link_to_remote pluralize(@idea.comments.size, 'comments'), :url => { :action => 'toggle_comments' }
    else
      link =  pluralize(@idea.comments.size, 'comments')
    end 
    link
  end
  
  def releases_with_all_and_unscheduled product_id
    entries = []
    entries << {:name => "Unscheduled", :key => 0}
    entries << {:name => "All Releases", :key => -1}
    all_releases_with_misc product_id, entries
  end
  
  def search_box_display_style
    return "display:none;" if session[:idea_search_box_display] == "HIDE"
    return "display:block;"
  end
  
  def search_box_image
    image = "hide.png"
    help = "Hide search box"
    if session[:idea_search_box_display] == "HIDE"
      image = "show.png" 
      help = "Show search box"
    end
    theme_image_tag("icons/16x16/#{image}", :alt=> help, :title=> help,:onmouseover => "Tip('#{help}')")
  end

  protected

  def all_releases_with_misc product_id, misc_entries
    releases = []
    for entry in misc_entries
      releases << [entry[:name], entry[:key]]
    end
    for release in Release.find_all_by_product_id(product_id, :order => "version ASC")
      releases << ["#{release.version} (#{release.release_status.description})", release.id]
    end
    releases
  end

  def announcement_link announcement
    text = truncate(announcement.headline, 26)
    if announcement.unread?(current_user)
      text = "<b>#{truncate(announcement.headline, 22)}</b>"
    end
    link_to text, "#{announcements_path}##{announcement.id}"
  end  
  
  def tab_class type
    class_string = 'class="selected"' if session[:selected_tab] == type
    class_string
  end
  
  def tab_body_display selected
    return "display:none;" if !selected
    "display:block;"
  end
  
  def render_tab_body
    render(:partial => tab_body_partial, :object => @idea)
  end
  
  private

  def show_release idea
    show = ""
    if idea.release.nil?
      show = "-"
    else
      show = "#{idea.release.version} (#{idea.release.release_status.description})" 
    end
    show
  end   
end