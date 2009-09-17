##
# Copyright (c) The Nambu Network Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
# is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
##

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

  ## The intent is to version the API, but this was thought of after these routes unversioned routes were published. There is
  ## likely a better way do this, perhaps by some sort of "alias", but The Google had nadda.  
  ## Initial Unversioned API routes (with their legacy partners)

  ## Legacy API Routes, with their version counterparts.
  map.connect '/api/shorteners.:format', :controller => "one/static", :action => "shorteners"
  map.connect '/v1/shorteners.:format', :controller => "one/static", :action => "shorteners"

  map.connect '/api/trim_url.:format', :controller => "one/url", :action => "trim_url"
  map.connect '/api/trim_simple', :controller => "one/url", :action => "trim_simple"
  map.connect '/api/trim_reference.:format', :controller => "one/url", :action => "trim_reference"
  map.connect '/api/trim_destination.:format', :controller => "one/url", :action => "trim_destination"
  map.connect '/api/trim_claim.:format', :controller => "one/url", :action => "trim_claim"
  map.connect '/v1/trim_url.:format', :controller => "one/url", :action => "trim_url"
  map.connect '/v1/trim_simple', :controller => "one/url", :action => "trim_simple"
  map.connect '/v1/trim_reference.:format', :controller => "one/url", :action => "trim_reference"
  map.connect '/v1/trim_destination.:format', :controller => "one/url", :action => "trim_destination"
  map.connect '/v1/trim_claim.:format', :controller => "one/url", :action => "trim_claim"

  map.connect '/api/url_visits.:format', :controller => "one/statistics", :action => "url_visits"
  map.connect '/api/url_activity.:format', :controller => "one/statistics", :action => "url_activity"
  map.connect '/v1/url_visits.:format', :controller => "one/statistics", :action => "url_visits"
  map.connect '/v1/url_activity.:format', :controller => "one/statistics", :action => "url_activity"

  map.connect '/api/verify.:format', :controller => "one/account", :action => "verify"
  map.connect '/api/account_urls.:format', :controller => "one/account", :action => "account_urls"
  map.connect '/api/account_visits.:format', :controller => "one/account", :action => "account_visits"
  map.connect '/api/account_ttrims.:format', :controller => "one/account", :action => "account_ttrims"
  map.connect '/v1/verify.:format', :controller => "one/account", :action => "verify"
  map.connect '/v1/account_urls.:format', :controller => "one/account", :action => "account_urls"
  map.connect '/v1/account_visits.:format', :controller => "one/account", :action => "account_visits"
  map.connect '/v1/account_ttrims.:format', :controller => "one/account", :action => "account_ttrims"
  
  ## Strictly Versioned 1.0 API Routes
  map.connect 'v1/shorten', :controller => "one/bitly", :action => "shorten"
  map.connect 'v1/expand',  :controller => "one/bitly", :action => "expand"

  map.connect 'v1/upload', :controller => "one/image", :action => "upload"
  map.connect 'v1/uploadAndPost', :controller => "one/image", :action => "upload_and_post"

  ## Strictly Versioned 2.0 API Routes
  ## TBA

  ## See how all your routes lay out with "rake routes"  
  ## Public Routes
  map.root :controller => "welcome"

  ## Install the default routes as the lowest priority.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'

  ## Catchall Route for the "NO ACTIONS"
  map.connect '*path', :controller => "welcome", :action => "catchall"
end
