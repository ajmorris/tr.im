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

class TweetController < ApplicationController
  before_filter :ajax?, :set_tlds, :set_url_returns
  before_filter :set_oauths, :only => [ :share, :retweet ]
  before_filter :set_marklet, :only => [ :index ]
  before_filter :set_menu_resets, :only => [ :retweet ]
  before_filter :get_trimform_reset, :only => [ :retweet ]

  def tweet
    if (not params.has_key?("tweet")) && (not params[:tweet].is_a?(Hash)) && (not has_parameters?(params[:tweet], %w(oauth_id)))
      render :partial => "tweet_noacct", :locals => { :error_text => t(:account_none, :scope => :tweet) }

    elsif not has_parameters?(params[:tweet], %w(text oauth_id trim_url_id)) && params[:tweet][:text].rstrip.length > TrimTweet::MINIMUM_TWEET_LENGTH
      @tweet_text = params[:tweet][:text].rstrip
      @ok_to_tweet = false
      if owns_oauth?(params[:tweet][:oauth_id].to_i) && TrimUrl.exists?(params[:tweet][:trim_url_id].to_i)
        @ok_to_tweet = true
        @tweet_oauth = NetworkOAuth.find(params[:tweet][:oauth_id].to_i, :include => [ :network ])
      else
        logger.info "Unauthorized Access on Network ID SELECT [SHOULD NOT HAPPEN -- Fraudulent Post Data?]"
        render :partial => "tweet_error", :locals => { :error_text => t(:account_taken, :scope => :tweet) } end

      if @ok_to_tweet
        begin
          case @tweet_oauth.network_id
          when Network::TWITTER
            twtt = NCTwitterOAuth.new(WEBSITE_CONFIG['twitter_key'], WEBSITE_CONFIG['twitter_secret'], @tweet_oauth.acs_token, @tweet_oauth.acs_secret)
            json = twtt.submit_tweet(@tweet_text)
            tweet_id = json["id"].to_i
            tweet_user_id = json["user"]["id"]
            tweet_user_image_url = json["user"]["profile_image_url"]
          end

        rescue NCNotAuthorized
          render :partial => "tweet_error", :locals => { :error_text => t(:badlogin, :scope => :tweet) }
        rescue NCRateLimited
          logger.info "#{@tweet_network.name} Sent STATUS 400 -- Rate Limited?"
          render :partial => "tweet_error", :locals => { :error_text => t(:limited, :scope => :tweet) }
        rescue NCGeneralFailure
          render :partial => "tweet_error", :locals => { :error_text => t(:timeout, :scope => :tweet) }

        else
          logger.info "Status Update to [#{@tweet_oauth.network.name}] Succeeded?"
          set_activity("TWEET")

          if has_session?
            trim_tweet = TrimTweet.new do |tt|
              tt[:oauth_id] = @tweet_oauth.id
              tt[:user_id] = @user.id
              tt[:trim_url_id] = params[:tweet][:trim_url_id]å
              tt[:tweet] = @tweet_text
              tt[:tweet_id] = tweet_id
              tt[:remote_id] = tweet_user_id
            end
            trim_tweet.save
          end

          session[:last_tweet_id] = @tweet_oauth.id
          session[:last_tweet_username] = @tweet_oauth.username
        end
      end
    else
      render :partial => "tweet_notweet", :locals => { :error_text => t(:notweet, :scope => :tweet) } end
  end
  
  def retweet
    if TrimUrl.exists?(params[:id])
      @trim_url = TrimUrl.find(params[:id])
      render :partial => "retweet"
    else
      render :nothing => true end
  end
end
