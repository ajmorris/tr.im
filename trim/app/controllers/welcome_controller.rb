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

require 'cgi'

class WelcomeController < ApplicationController
  before_filter :set_not_marklet
  before_filter :set_url_returns, :only => [ :index ]
  before_filter :set_tlds, :only => [ :index ]
  before_filter :set_trims_with_charts, :only => [ :index ]
  
  def index
    @pt = "#{WEBSITE_CONFIG['website_domain']} your URLs"
    @tab = "urls"
  end

  def features
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Features"
    @tab = "none"
  end
  def faqs
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Frequently Asked Questions"
    @tab = "none"
  end
  def api
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Application Programming Interface"
    @tab = "none"
  end
  def about
    @pt = "#{WEBSITE_CONFIG['website_domain']} | About Us"
    @tab = "none"
  end

  def nourl
    @pt = "#{WEBSITE_CONFIG['website_domain']} | #{WEBSITE_CONFIG['website_domain']} URL Does Not Exist"
    @tab = "none"
  end
  def catchall
    if params[:path][0] == "http:"
      redirect_to "/marklet?url=#{reassemble}"
    else
      redirect_to root_url end
  end
  
  protected
  ## 
  # There is very likely a better way to do this. We have all kinds of minor problems with the marklet being abused and some
  # legacy URLs that are still out there. Thank you, Wordpress.
  ##
  def reassemble
    tmps = params[:path].join("/")
    started, qs = false, String.new
    params.each_key do |k|
      if k != "controller" && k != "action" && k != "path"
        started ? qs << "&#{k}=#{params[k]}" : qs << "?#{k}=#{params[k]}"
        started = true
      end
    end
    tmps << CGI::escape(qs)
    logger.info "REASSEMBLED URL [#{tmps}]"
    return tmps
  end
end
