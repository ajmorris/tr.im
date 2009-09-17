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

require 'json'

class OAuthController < ApplicationController
  before_filter :set_oauths, :only => [ :authorized ]

  ## This method is for creating a network OAuth for use with a session ID or user session at the time of an action of
  ## some sort, such as tweeting or commenting. One calls it to get redirected to Twitter.

  def inline
    request_token = get_network_oauth_request_token(Network::TWITTER)
    logger.info "REQUEST TOKEN KEY: #{request_token.token}"
    logger.info "REQUEST TOKEN SECRET: #{request_token.secret}"
    session[:oauth_reqtoken_token] = request_token.token.to_s
    session[:oauth_reqtoken_secret] = request_token.secret.to_s

    oauth = NetworkOAuth.new do |o|
      o.website_id = WEBSITE_CONFIG['website_id']
      o.network_id = Network::TWITTER
      o.username = NetworkOAuth::DEFAULT_USERNAME
      o.user_id = 0
      o.req_token = request_token.token
      o.status = NetworkOAuth::STATUS_PENDING
    end
    oauth.save

    if has_session?
      logger.info "ON CALLBACK: Attaching with UserOAuth()"
      user_oauth = UserOAuth.new do |uo|
        uo[:user_id] = @user.id
        uo[:oauth_id] = oauth.id
      end
      user_oauth.save
    else
      logger.info "ON CALLBACK: Attaching with SessionOAuth()"
      session_oauth = SessionOAuth.new do |so|
        so[:oauth_id] = oauth.id
        so[:session_id] = request.session_options[:id]
      end
      session_oauth.save
    end
    
    session[:oauth_return_url] = "#{WEBSITE_CONFIG['website_url']}website/oauth/completed"
    redirect_to request_token.authorize_url
  end
  def authorized
    render :update do |page|
      page.replace_html 'tweet_accounts', :partial => "shared/tweet_oauths" end
  end
  def completed
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Authorization Completed"
    @tab = "none"
    @tagline = "#{WEBSITE_CONFIG['website_domain']} Authorization Completed"
  end


  ##
  # CALLBACKS
  # Twitter Parameters: "oauth_token"=>"35yxy9zpdr8mFLnOI4YWpTJjJ767GNwR2grHlEWkzQ", "oauth_verifier" => "IamS0rpgRAus3Qfvz0za1koT45kaN096TKnLT94Ic"
  # For Twitter we then have to call verify with the token to get the username and user_id for the user, and
  # use that data to setup the NetworkOAuth record. Fun fun.
  ##

  def twitter
    if (not params[:oauth_token].blank?)
      if NetworkOAuth.exists?({ :req_token => params[:oauth_token] }) 

        consumer = OAuth::Consumer.new(WEBSITE_CONFIG['twitter_key'], WEBSITE_CONFIG['twitter_secret'], { :site => "http://twitter.com" })
        request_token = OAuth::RequestToken.new(consumer, session[:oauth_reqtoken_token], session[:oauth_reqtoken_secret])
        access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
        ## request_token = consumer.get_request_token(:oauth_callback => WEBSITE_CONFIG['twitter_callback'])

        ## logger.info "ACCESS TOKEN: #{access_token.token}"
        ## logger.info "ACCESS SECRET: #{access_token.secret}"

        response = consumer.request(:get, '/account/verify_credentials.json', access_token, { :scheme => :query_string })
        case response
        when Net::HTTPSuccess
          creds = JSON.parse(response.body)
          ## logger.info "JSON Result -- #{creds.inspect}"
        else
          logger.info "TWITTER OAUTH Failed to VERIFY."
          redirect_to WEBSITE_CONFIG['website_url'] 
        end

        NetworkOAuth.all(:conditions => { :website_id => WEBSITE_CONFIG['website_id'],
                                          :network_id => Network::TWITTER,
                                          :user_id => creds["id"].to_i,
                                          :status => NetworkOAuth::STATUS_DONE }).each {|oauth| NetworkOAuth.destroy(oauth.id) }

        oauth = NetworkOAuth.first(:conditions => { :req_token => params[:oauth_token] })
        oauth[:username] = creds["screen_name"]
        oauth[:user_id] = creds["id"].to_i
        oauth[:acs_token] = access_token.token
        oauth[:acs_secret] = access_token.secret
        oauth[:status] = NetworkOAuth::STATUS_DONE
        oauth.save!
                
        ## We had a tr.im claimant record to turn this feature ON which is the desired default for all network authorized
        ## accounts, when logged in.

        if has_session?
          trim_claimant = TrimClaimant.new do |tc|
            tc[:user_id] = @user.id
            tc[:oauth_id] = oauth.id
          end
          trim_claimant.save
        end

        ## Confirmation for the token to ensure it will work from scratch with a fresh request. This is also the basis for
        ## any OAuth based API calls.

        # logger.info "TEST FRESH OAuth Request [#{oauth.inspect}]"
        # testcons = OAuth::Consumer.new(WEBSITE_CONFIG['twitter_key'], WEBSITE_CONFIG['twitter_secret'], { :site => "http://twitter.com" })
        # testtokn = OAuth::AccessToken.new(testcons, oauth.acs_token, oauth.acs_secret)
        # response = testcons.request(:get, '/favorites.json', testtokn, { :scheme => :query_string })
        # logger.info response.inspect
        # logger.info response.body.inspect

        ## FINISH UP ...
        
        flash[:oauth_just_done] = true
        session[:oauth_reqtoken_token] = nil
        session[:oauth_reqtoken_secret] = nil
        redirect_to session[:oauth_return_url]
      
      else redirect_to WEBSITE_CONFIG['website_url'] end
    else redirect_to WEBSITE_CONFIG['website_url'] end
  end
end
