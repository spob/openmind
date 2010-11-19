
ActionController::Routing::Routes.draw do |map|
  
  # The priority is based upon order of creation: first created -> highest
  # priority.
  
  # Sample of regular route: map.connect 'products/:id', :controller =>
  # 'catalog', :action => 'view' Keep in mind you can assign values other than
  # :controller and :action
  
  # Sample of named route: map.purchase 'products/:id/purchase', :controller =>
  # 'catalog', :action => 'purchase' This route can be invoked with
  # purchase_url(:id => product.id)
  
  map.resources :allocations, :collection => { :export_import => :get,
    :export => :post, :import => :post, :toggle_pix => :get }
  map.resources :announcements, :collection => { :preview => :get, :rss => :get }
  map.resources :attachments, :member => { :download => :get, :html => :get },
  :collection => { :search => :get }
  map.resources :comments, :collection => { :preview => :get },
  :member => { :endorse => :post, :unendorse => :post, :attach => :get,
    :privatize => :post, :publicize => :post, :promote_power_user => :post }
  map.resources :enterprises, :member => { :next => :get, :previous => :get },
  :collection => { :search => :get, :auto_complete_for_enterprise_name => :get }
  map.resources :forums, :collection => { :search => :get, 
    :rss => :get, :tag => :get, :metrics => :get, :metrics_graphs => :get,
    :open_count_graphs => :get, :days_pending_graphs => :get, :pending_count_graphs => :get}, 
    :member => { :mark_all_as_read => :post }
  map.resources :groups
  map.resources :hotfixes
  map.resources :link_sets, :member => { :update_sort => :post }
  map.resources :lookup_codes
  map.resources :merge_ideas
  map.resources :periodic_jobs, :member => { :rerun => :post, :runnow => :post }
  map.resources :polls, :member => { :publish => :post, :unpublish => :post, :pie => :get,
    :present_survey => :get, :take_survey => :post}, 
  :collection => {:toggle_details => :get, :display_comments => :get }
  map.resources :portal, :only => :index,
  :collection => {:auto_complete_for_user_email => :get }
  map.resources :products
  map.resources :releases, :member => { :commit => :post },
  :collection => { :preview => :get, :list => :get, :check_for_updates => :get, 
  :compatibility => :get }
  map.resources :topics, :collection => { :preview => :get, :search => :get,
    :tag => :get }, :member => {:rate => :post, :toggle_status => :put}
  map.resources :user_logons
  map.resources :user_requests, :member => { :approve => :post, :reject => :post,
    :acknowledge => :get, :next => :get, :previous => :get },
  :collection => {:auto_complete_for_user_request_enterprise_name => :get }
  map.resources :votes, :collection => { :create_from_show => :post }
  # NOTE: create_topic_watch really should just support a post. That said,
  # googlebot hits that page and tries to do a create_topic_watch with a git,
  # which fills the hoptoadapp log...so we'll handle enforcement down at
  # the controller level instead
  map.resources :watches, :member => { :create_topic_watch => [:post, :get],
    :destroy_topic_watch => :delete, :create_forum_watch => :post,  
    :create_product_watch => :post, 
    :create_product_watch_from_check_for_update => :post, :destroy_forum_watch => :delete,
    :destroy_product_watch => :delete},
  :collection => {:create_from_show => :post,
    :create_product_watches => :get }
  
  # Allow downloading Web Service WSDL as a file with an extension instead of a
  # file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  # Default home page #map.connect '', :controller => 'ideas', :action =>
  # 'index'
  map.home '', :controller => 'ideas', :action => 'index'
  
  # Install the default route as the lowest priority.
  map.connect 'download/:id', :controller => 'attachments', :action => 'download'
  map.connect 'html/:id', :controller => 'attachments', :action => 'html'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action.:format'
  
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  #  map.connect ':id', :controller => 'ideas', :action => 'show'
  
  map.connect ':path', :controller => 'static'
end
