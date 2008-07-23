ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  
  map.resources :allocations, :collection => { :export_import => :get,
    :export => :post, :import => :post, :toggle_pix => :get }
  map.resources :announcements, :collection => { :preview => :get, :rss => :get }
  map.resources :comments, :collection => { :preview => :get }
  map.resources :enterprises
  map.resources :forums
  map.resources :lookup_codes
  map.resources :merge_ideas
  map.resources :polls, :member => { :publish => :post, :unpublish => :post,
    :present_survey => :get, :take_survey => :post}, 
    :collection => {:toggle_details => :get, :pie => :get }
  map.resources :products
  map.resources :releases, :member => { :commit => :post },
      :collection => { :preview => :get, :list => :get }
  map.resources :topics, :collection => { :preview => :get }
  map.resources :user_logons
  map.resources :votes, :collection => { :create_from_show => :post }
  map.resources :watches, :member => { :create_topic_watch => :post,  
    :destroy_topic_watch => :delete, :create_forum_watch => :post,  
    :destroy_forum_watch => :delete }, 
    :collection => {:create_from_show => :post }

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Default home page
  #map.connect '', :controller => 'ideas', :action => 'index'
  map.home '', :controller => 'ideas', :action => 'index'
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  
#  map.connect ':id', :controller => 'ideas', :action => 'show'

  map.connect ':path', :controller => 'static'
end
