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

  ## See how all your routes lay out with "rake routes"
  ## Redirect Routes
  map.connect ':trim_url',  :controller => "redirect"
  map.connect ':trim_url.', :controller => "redirect"
  map.connect ':trim_url,', :controller => "redirect"
  map.connect ':trim_url;', :controller => "redirect"

  ## Public Routes
  map.root :controller => "welcome"

  ## Install the default routes as the lowest priority.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'

  ## Catchall Route for the "NO ACTIONS"
  map.connect '*path', :controller => "welcome", :action => "catchall"
end
