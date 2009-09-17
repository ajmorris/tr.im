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

class Account::NetworkController < ApplicationController
  before_filter :has_session_with_redirect?
  before_filter :set_networks, :only => [ :index ]

  def index
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Account | Authorizations"
    @sb = "networks"
    @tab = "account"
    @tagline = "#{WEBSITE_CONFIG['website_domain']} Authorizations"
  end

  def authorize
    request_token = get_network_oauth_request_token(Network::TWITTER)
    logger.info "REQUEST TOKEN KEY: #{request_token.token}"
    logger.info "REQUEST TOKEN SECRET: #{request_token.secret}"
    session[:oauth_reqtoken_token] = request_token.token.to_s
    session[:oauth_reqtoken_secret] = request_token.secret.to_s

    oauth = NetworkOAuth.new do |o|
      o[:website_id] = WEBSITE_CONFIG['website_id']
      o[:network_id] = Network::TWITTER
      o[:username] = NetworkOAuth::DEFAULT_USERNAME
      o[:user_id] = 0
      o[:req_token] = request_token.token
      o[:status] = NetworkOAuth::STATUS_PENDING
    end
    oauth.save

    user_oauth = UserOAuth.new do |uo|
      uo[:user_id] = @user.id
      uo[:oauth_id] = oauth.id
    end
    user_oauth.save

    session[:oauth_return_url] = "#{WEBSITE_CONFIG['website_url']}account/network"
    redirect_to request_token.authorize_url
  end
  
  def destroy
    if NetworkOAuth.exists?(params[:id].to_i) && @user.owns_this_oauth?(params[:id].to_i)
      NetworkOAuth.destroy(params[:id].to_i)
      @user.oauths(true)
    end
    render :update do |page|
      page.replace_html 'oauth_accounts', :partial => "accounts" end
  end
end

