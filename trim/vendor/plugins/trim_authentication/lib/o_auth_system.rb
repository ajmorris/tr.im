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

##
# Example:
#   redirect_to get_network_oauth_request_token(Network::TWITTER).authorize_url
##

module OAuthSystem
  protected
  def set_oauths
    @oauths = Array.new
    if has_session?
      @oauths = @user.oauths_at_website(WEBSITE_CONFIG['website_id']) if @user.has_oauth_at_website?(WEBSITE_CONFIG['website_id'])
    else
      SessionOAuth.all(:conditions => { :session_id => request.session_options[:id] }).each {|sa| @oauths << sa.oauth if sa.oauth } end
  end
  
  def oauth_has_avatar?(network_id, remote_id)
    case network_id
    when Network::TWITTER
      return true if TwitterUser.exists?(remote_id)
    end
    return false
  end
  def get_avatar_url_for_oauth(network_id, remote_id)
    case network_id
    when Network::TWITTER
      return TwitterUser.find(remote_id).image_url
    end
    return false
  end
  
  def get_network_oauth_request_token(network_id)
    case network_id
    when Network::TWITTER
      cons = OAuth::Consumer.new(WEBSITE_CONFIG['twitter_key'], WEBSITE_CONFIG['twitter_secret'], { :site => "http://twitter.com" })
      return cons.get_request_token(:oauth_callback => WEBSITE_CONFIG['twitter_callback'])
    end
    return nil
  end

  def owns_oauth?(oauth_id)
    return true if oauth_belongs_to_session?(oauth_id)
    return oauth_belongs_to_account?(oauth_id)
  end
  def oauth_belongs_to_account?(oauth_id)
    return UserOAuth.exists?({ :user_id => @user.id, :oauth_id => oauth_id }) if @user
    return false
  end
  def oauth_belongs_to_session?(oauth_id)
    SessionOAuth.exists?({ :session_id => request.session_options[:id], :oauth_id => oauth_id })
  end
  
  def set_session_oauths_as_user_oauths
    for session_oauth in SessionOAuth.all(:conditions => { :session_id => request.session_options[:id] })
      SessionOAuth.transaction do
        if not UserOAuth.exists?({ :user_id => @user.id, :oauth_id => session_oauth.oauth_id })
          UserOAuth.create!(:user_id => @user.id, :oauth_id => session_oauth.oauth_id)
        end
      end
    end
  end
end
