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

class ApplicationController < ActionController::Base
  before_filter :set_ipaddress, :set_user_agent, :set_language, :set_timezone, :set_user_last_seen, :set_networks
  before_filter :set_trim_preferences, :set_session_urls_in_db

  protect_from_forgery :only => [ :create, :update, :delete ]
  filter_parameter_logging :password
  helper :all
  helper_method :word_website
  helper_method :get_trim_url, :get_display_url, :get_cached_agent, :has_urls?, :beta?, :laptop?

  protected
  ## This method is referenced in shared partials. Shared partials will be done away with in future version of tr.im
  ## since they are no longer needed.

  def word_website
    "<span>tr</span><span class=\"trimdot\">.</span><span>im</span>"
  end

  def redirect_layouts
    set_trim_preferences
    set_user_last_seen
  end

  def set_marklet
    @marklet = true
    @marklet_errors = true
    session[:marklet] = true
  end
  def set_not_marklet
    @marklet = false
    @marklet_errors = false
    session[:marklet] = false
    session[:marklet_domain] = nil
    session[:marklet_referer] = nil
  end

  ## These are for development. Laptop or beta versions will work and run through those respective servers as needed
  ## for these URLs.
  
  def get_trim_url(trim_url)
    "http://#{request.env['HTTP_HOST']}/#{trim_url.shortening.surl}"
  end
  def get_display_url(trim_url)
    "http://tr.im/#{trim_url.shortening.surl}"
  end
  def get_trim_url_with_surl(surl)
    "http://#{request.env['HTTP_HOST']}/#{surl}"
  end
  
  def set_menu_resets
    @menu_resets  = "Element.removeClassName('menu_destinations', 'current');"
    @menu_resets << "Element.removeClassName('menu_share', 'current');"
    @menu_resets << "Element.removeClassName('menu_summaries', 'current');"
    @menu_resets << "Element.removeClassName('menu_urls', 'current');"
  end
  def get_trimform_reset
    @trim_resets  = "$('URLF_url').setStyle({border: '1px solid #A5C1D1'});"
    @trim_resets << "Form.Element.setValue('URLF_url', '');"
    @trim_resets << "Form.Element.setValue('options_custom', '');"
    @trim_resets << "Form.Element.setValue('options_privacy', '');"
    @trim_resets << "$('options_custom').setStyle({border: '1px solid #A5C1D1'});"
    @trim_resets << "$('options_privacy').setStyle({border: '1px solid #A5C1D1'});"
  end
end
