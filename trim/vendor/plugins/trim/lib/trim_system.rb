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

require 'top_level_domain'
require 'network'
require 'url_return'
require 'url_destination'
require 'trim_url'
require 'trim_action'
require 'trim_preferences_anonymous'

module TrimSystem
  protected
  def get_absolute_url(trailing_slash = false)
    return "http://#{request.env['HTTP_HOST']}/" if trailing_slash
    return "http://#{request.env['HTTP_HOST']}"
  end

  def ajax?
    return true if request.xhr?
    redirect_to "/"
    return false
  end
  def beta?
    request.env["SERVER_NAME"].start_with?("localhost") || request.env["SERVER_NAME"].start_with?("swan")
  end
  def laptop?
    request.env["SERVER_NAME"].start_with?("localhost")
  end

  def set_url_returns
    @url_returns = Rails.cache.fetch('url_returns', :expires_in => 2.hours) {
      UrlReturn.all(:conditions => { :display => 'YES' }, :order => "ordernum")
    }
  end
  def set_url_sorts
    @url_sorts = {
      TrimUrl::URLSORT_DESTINATION => "Destination URL",
      TrimUrl::URLSORT_VISITS => "Visits",
      TrimUrl::URLSORT_TRIMMED => "tr.immed Date"
    }
  end
  def set_tlds
    @tlds = Rails.cache.fetch("tlds", :expires_in => 24.hours) { TopLevelDomain.all }
  end
  def set_networks
    @networks = Rails.cache.fetch("networks", :expires_in => 2.hours) { Network.all }
  end
  def get_cached_network(network_id)
    @networks.detect {|n| n.id == network_id }
  end

  def set_inline_width
    @inline_width = WEBSITE_CONFIG['inline_width_default']
    @inline_width = UserAgent::IPHONE_WIDTH if @user_agent.is_iphone?
    @inline_width = params[:width].to_i if params[:width].to_i > @inline_width && params[:width].to_i < WEBSITE_CONFIG['inline_width_maximum']
    logger.info "INLINE Width SET [#{@inline_width}]"
  end
  
  def set_trims(override = false, override_length = TrimsList::MAX_URLS_IN_LIST)
    urls_needed = @trim_preferences.urls_per_page
    urls_needed = override_length if override
    urls_start  = 0 if params[:page] == nil || params[:page].to_i <= 1
    urls_start  = ((params[:page].to_i - 1) * urls_needed) if params[:page].to_i > 1
    logger.info "URLs Pagination SET [START: #{urls_start} -- SIZE: #{urls_needed}]"

    if has_session?
      @trims_list = TrimsList.new(:user_id => @user.id,
                                  :sort_option => @trim_preferences.urlsort, :urls_start => urls_start, :urls_needed => urls_needed)
    else
      @trims_list = TrimsList.new(:session_id => request.session_options[:id],
                                  :sort_options => @trim_preferences.urlsort, :urls_start => urls_start, :urls_needed => urls_needed) end

    set_trims_pagination(urls_needed)
  end
  def set_trims_with_charts(override = false, override_length = TrimsList::MAX_URLS_IN_LIST, maxwidth = 835)
    set_trims(override, override_length)
    @trims_list.set_charts(@trim_preferences.charts, maxwidth) if @trims_list
  end
  def set_trims_with_search(search_tags = [])
    if search_tags.empty?
      set_trims
    else
      if has_session?
        @trims_list = TrimsList.new(:user_id => @user.id,
                                    :sort_option => @trim_preferences.urlsort,
                                    :urls_start => 0, :urls_needed => 100000, :search_tags => search_tags)
      else
        @trims_list = TrimsList.new(:session_id => request.session_options[:id],
                                    :sort_options => @trim_preferences.urlsort,
                                    :urls_start => 0, :urls_needed => 100000, :search_tags => search_tags) end
    end
    set_trims_pagination(10000)
  end
  def set_trims_pagination(urls_needed)
    if has_urls?
      @user_urls = @trims_list.all_trims.paginate :page => params[:page] == nil ? 1 : params[:page], :per_page => urls_needed
      @user_urls_total = @trims_list.all_trims.length
    else @user_urls, @user_urls_total = Array.new, 0 end
  end
  
  def set_top_trims(maximum = TopTrims::DEFAULT_MAXIMUM)
    @top_trims = Rails.cache.fetch("toptrims_#{@user.id}", :expires_in => 5.seconds) {
      tt = TopTrims.new(@user.id, maximum)
      tt.trims_by_clicks
    }
  end
  

  def has_urls?
    return @trims_list.has_trims? if @trims_list
    return false
  end
  def has_session_urls?
    return @trims_list.has_session_trims? if @trims_list
    return false
  end

  def owns_trim?(trim_url_id)
    return true if trim_belongs_to_session?(trim_url_id)
    return trim_belongs_to_account?(trim_url_id)
  end
  def trim_belongs_to_account?(trim_url_id)
    return @trims_list.trim_belongs_to_account?(trim_url_id) if @trims_list && (not @trims_list.empty?)
    return TrimUserUrl.exists?({ :user_id => @user.id, :trim_url_id => trim_url_id }) if @user
    return false
  end
  def trim_belongs_to_session?(trim_url_id)
    return @trims_list.trim_belongs_to_session?(trim_url_id) if @trims_list
    return TrimSessionUrl.exists?({ :session_id => request.session_options[:id], :trim_url_id => trim_url_id })
  end
  def add_trim_to_session(trim_url_id)
    if not TrimSessionUrl.exists?({ :session_id => request.session_options[:id], :trim_url_id => trim_url_id })
      TrimSessionUrl.create!(:session_id => request.session_options[:id], :trim_url_id => trim_url_id)
    end
  end
  
  
  ## Methods for syncing session URLs into the DB. This is a legacy thing for when session URL IDs used
  ## to be stored within the sessions themselves.
  
  def set_session_urls_in_db
    if session[:user_urls]
      session[:user_urls].each do |id|
        TrimSessionUrl.transaction do 
          if TrimUrl.exists?(id)
            if not TrimSessionUrl.exists?({ :trim_url_id => id })
              logger.info "ADDING Session URL to DB [#{id}]"
              TrimSessionUrl.create!(:session_id => request.session_options[:id], :trim_url_id => id)
            else
              logger.info "SESSION URL ALREADY OWNED! [#{id}] Huh?" end
          else
            logger.info "SESSION TRIM URL NO LONGER EXISTS [#{id}]" end
        end
      end
      session[:user_urls] = nil
    end
  end
  def set_session_urls_as_user_urls
    for session_url in TrimSessionUrl.all(:conditions => { :session_id => request.session_options[:id] })
      TrimUserUrl.transaction do
        if not TrimUserUrl.exists?({ :trim_url_id => session_url.trim_url_id })
          TrimUserUrl.create!(:user_id => @user.id, :trim_url_id => session_url.trim_url_id)
        end
      end
      session_url.destroy
    end
  end
  
  
  ## Set the trim_preferences object for the user session. We use one set of preferences for all the tr.im
  ## websites.
  
  def set_trim_preferences
    if has_session?
      if ups = TrimPreferencesUser.first(:conditions => { :user_id => @user.id })
        @trim_preferences = ups.preferences end
    end
    ss = request.session_options[:id]
    if aps = TrimPreferencesAnonymous.first(:conditions => { :session_id => ss })
      if @trim_preferences
        TrimPreferencesAnonymous.update_all("prefs_id = #{@trim_preferences.id}", "session_id = '#{ss}'")
      else @trim_preferences = aps.preferences end
    else
      @trim_preferences = TrimPreferences.create! unless @trim_preferences
      trim_preferences_anon = TrimPreferencesAnonymous.create!(:prefs_id => @trim_preferences.id, :session_id => ss) end
  end
  
  
  ## Recording tr.im activity to generate reports of what is happening on tr.im websites, outside of basic Google data.
  ## This is ised to enforce a rate limit on the website URL creation form.

  def set_activity(action)
    trim_actions = Rails.cache.fetch('trim_actions', :expires_in => 2.hours) { TrimAction.all }
    trim_action = trim_actions.find {|i| i.action == action }
    if trim_action
      trim_activity = TrimActivity.new(:action_id => trim_action.id) do |ta|
        ta[:session_id] = TrimObject.get_random_code(48)
        ta[:session_id] = request.session_options[:id] if defined?(session) && defined?(request.session_options[:id])
        ta[:ip_address] = @remote_ip
      end
      trim_activity.save!
    else RAILS_DEFAULT_LOGGER.info "UNKNOWN TRIM ACTIVITY [#{action}]" end
  end
  def get_activity_count(action, since_value)
    trim_actions = Rails.cache.fetch('trim_actions', :expires_in => 2.hours) { TrimAction.all }
    trim_action = trim_actions.find {|i| i.action == action }
    if TrimActivity.exists?({ :session_id => request.session_options[:id] })
      return TrimActivity.count(:id, :conditions => ["session_id = ? AND action_id = ? AND created_at > ?",
                                                     request.session_options[:id], trim_action.id, since_value])
    else
      return TrimActivity.count(:id, :conditions => ["(session_id = ? OR ip_address = ?) AND action_id = ? AND created_at > ?",
                                                     request.session_options[:id], @remote_ip, trim_action.id, since_value]) end
  end
end
