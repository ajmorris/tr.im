ActionController::Routing::Routes.draw do |map|
  ## The priority is based upon order of creation: first created -> highest priority.

  ## Sample of regular route:
  ##   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  ## Keep in mind you can assign values other than :controller and :action

  ## Sample of named route:
  ##   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  ## This route can be invoked with purchase_url(:id => product.id)

  ## Sample resource route (maps HTTP verbs to controller actions automatically):
  ##   map.resources :products

  ## Sample resource route with options:
  ##   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  ## Sample resource route with sub-resources:
  ##   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  ## Sample resource route with more complex sub-resources
  ##   map.resources :products do |products|
  ##     products.resources :comments
  ##     products.resources :sales, :collection => { :recent => :get }
  ##   end

  ## Sample resource route within a namespace:
  ##   map.namespace :admin do |admin|
  ##     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  ##     admin.resources :products
  ##   end
  
  ## These used to shared with pic.im and could be shared with additional websites combined with tr.im if you are
  ## so inclined.
  map.help_change 'website/help/change', :controller => "help", :action => "change"
  map.signup      'website/signup', :controller => "signup"
  map.signup_done 'website/signup/done', :controller => "signup", :action => "done"

  map.login_redirect 'login', :controller => "login"
  map.login_form     'login', :controller => "index"
  map.login    'website/login/login', :controller => "login", :action => "login"
  map.logout   'website/login/logout', :controller => "login", :action => "logout"
  map.auto     'website/auto/login/:reference', :controller => "login", :action => "auto"
  map.lost     'website/password/lost', :controller => "password", :action => "lost"
  map.reset    'website/password/reset', :controller => "password", :action => "reset"
  map.pupdate  'website/password/update', :controller => "password", :action => "update"
  map.delivery 'website/password/deliver', :controller => "password", :action => "deliver"

  ## For URL statistics we have a series of routes. We need to continue to support the following
  ## example URLs:
  ##   http://[tr.im:pic.im]/url/inline/?reference=AbCd&width=300
  ##   http://[tr.im:pic.im]/statistics/aBcD
  ##   http://[tr.im:pic.im]/statistics/inline/aBcD

  map.trim_stats  'statistics/:surl', :controller => "statistics"
  map.trim_inline 'statistics/inline/:reference', :controller => "statistics", :action => "inline"
  map.trim_url_inline 'url/inline', :controller => "statistics", :action => "inline"
  map.trim_summary 'statistics/summary/:surl', :controller => "statistics", :action => "summary"
  map.trim_timelines 'statistics/timelines/:surl', :controller => "statistics", :action => "timelines"
  map.trim_locations 'statistics/locations/:surl', :controller => "statistics", :action => "locations"
  map.trim_agents 'statistics/agents/:surl', :controller => "statistics", :action => "agents"
  map.trim_referers 'statistics/referers/:surl', :controller => "statistics", :action => "referers"
  map.trim_shares 'statistics/shares/:surl', :controller => "statistics", :action => "shares"
  map.trim_details_agents 'statistics/details/agents/:reference', :controller => "statistics", :action => "details_agents"

  ## Account Administration
  map.trim_authorize "account/network/authorize", :controller => "account/network", :action => "authorize"
  map.toptrims 'account/toptrims', :controller => "account/welcome", :action => "toptrims"
  map.trimclaims 'account/claims', :controller => "account/claim"
  map.trimclaim_on 'account/claims/on/:username', :controller => "account/claim", :action => "on"
  map.trimclaim_off 'account/claims/off/:username', :controller => "account/claim", :action => "off"
  map.disqus_set 'account/disqus/set', :controller => "account/disqus", :action => "set"
  map.account 'account', :controller => "account/welcome", :action => "index"
  map.resource :account do |account|
    account.resources :network, :controller => "account/network", :path_prefix => 'account'
    account.resources :profile, :controller => "account/profile", :path_prefix => 'account'
    account.resources :username, :controller => "account/username", :path_prefix => 'account'
    account.resources :password, :controller => "account/password", :path_prefix => 'account'
    account.resources :email, :controller => "account/email", :path_prefix => 'account'
    account.resources :disqus, :controller => "account/disqus", :path_prefix => 'account'
    account.resources :timezone, :controller => "account/timezone", :path_prefix => 'account'
    account.resources :preferences, :controller => 'account/preferences', :path_prefix => 'account'
  end
  map.search  'website/search', :controller => "url", :action => "search"
  map.select  'website/select', :controller => "url", :action => "share"
  map.resources :trimurl, :controller => "url", :path_prefix => "website"

  ## Public Routes
  map.spam     'website/spam', :controller => "spam"
  map.spamr    'website/spam/report', :controller => "spam", :action => "report"
  map.extras   'website/extras', :controller => "extras"
  map.about    'website/about', :controller => "welcome", :action => "about"
  map.features 'website/features', :controller => "welcome", :action => "features"
  map.faqs     'website/faqs', :controller => "welcome", :action => "faqs"
  map.apidocs  'website/api', :controller => "welcome", :action => "api"

  map.tweet   'tweet', :controller => "tweet", :action => "tweet"
  map.retweet 'retweet/:id', :controller => "tweet", :action => "retweet"

  map.signup      'signup', :controller => "signup"
  map.signup_done 'signup/done', :controller => "signup", :action => "done"
  map.login_form  'login', :controller => "login"
  map.login       'login/login', :controller => "login", :action => "login"
  map.logout      'login/logout', :controller => "login", :action => "logout"
  map.lost        'password/lost', :controller => "password", :action => "lost"
  map.reset       'password/reset', :controller => "password", :action => "reset"
  map.reset_stats 'website/trimurl/reset/:id', :controller => 'url', :action => 'reset', :method => :post
  
  ## Section Routes
  map.section_destinations 'website/section/destinations', :controller => "section", :action => "destinations"
  map.section_share        'website/section/share', :controller => "section", :action => "share"
  map.section_summaries    'website/section/summaries', :controller => "section", :action => "summaries"
  map.section_urls         'website/section/urls', :controller => "section", :action => "urls"
  
  ## Miscellaneous Application Routes
  map.market '/marklet/', :controller => "marklet"
  
  ## The URL redirector route to catch a request with a random string by itself
  map.spamurl 'website/spam/redirect', :controller => "spam", :action => "redirect"
  map.nourl   'website/nourl', :controller => "welcome", :action => "nourl"

  ## See how all your routes lay out with "rake routes"
  map.root :controller => "welcome"

  ## Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  ## Catchall Route for the "NO ACTIONS"
  map.connect '*path', :controller => "welcome", :action => "catchall"
end
