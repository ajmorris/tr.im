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

class StatisticsController < ApplicationController
  before_filter :ajax?, :except => [ :index, :inline, :reset ]
  before_filter :set_countries
  before_filter :set_statistics_resets
  before_filter :set_titles, :only => [ :index ]
  before_filter :set_inline_width, :only => [ :inline ]
  before_filter :set_permission_with_surl, :except => [ :inline, :details_agents ]
  before_filter :set_permission_with_reference, :only => [ :details_agents ]
      
  def index
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Statistics"
    @pt << " | #{get_trim_url(@trim_url)}" if @has_statistics
    @tab = "urls"
    @has_user_urls = "YES"
    set_summaries
  end

  def summary
    set_summaries
  end
  def timelines
    @clicks_report = ClicksReport.new(@trim_url.id, ClicksReport::SITE_TRIM, ClicksReport::ASPECT_TIMELINES) if @stats_ok
  end
  def locations
    @clicks_report = ClicksReport.new(@trim_url.id, ClicksReport::SITE_TRIM, ClicksReport::ASPECT_LOCATIONS) if @stats_ok
  end
  def referers
    @clicks_report = ClicksReport.new(@trim_url.id, ClicksReport::SITE_TRIM, ClicksReport::ASPECT_REFERERS) if @stats_ok
  end
  def agents
    @clicks_report = ClicksReport.new(@trim_url.id, ClicksReport::SITE_TRIM, ClicksReport::ASPECT_AGENTS) if @stats_ok
  end

  def inline
    if TrimUrl.exists?({ :reference => params[:reference] })
      @trim_url = TrimUrl.first(:conditions => { :reference => params[:reference] })
      @inline_url = get_display_url(@trim_url)
      @clicks_report = ClicksReport.new(@trim_url.id)
      render :layout => "inline"
    else
      redirect_to "http://tr.im/" end
  end
  
  def details_agents
    @agents = Array.new
    if TrimUrl.exists?({ :reference => params[:reference] })
      @agents  = UserAgent.all(:select => "DISTINCT ua.*", :from => "user_agents ua, trim_clicks cs",
                               :conditions => ["cs.trim_url_id = ? AND cs.agent_id = ua.id", TrimUrl.find_by_reference(params[:reference]).id],
                               :order => "ua.id DESC")
      @agents.delete_if {|a| a.id == UserAgent::UNKNOWN }
      render :update do |page|
        page.replace_html "url_details", :partial => "agents"
        page << "Effect.Appear('url_details', { duration: 0.5 })" end
    else
      render :update do |page|
        page.replace_html "url_details", :partial => "agents" end end
  end
  
  protected
  def set_permission_with_surl
    @stats_ok = false
    if UrlShortening.exists?({ :shortener_id => UrlShortener::ID_TRIM, :surl => params[:surl] })
      @shortening = UrlShortening.first(:conditions => { :shortener_id => UrlShortener::ID_TRIM, :surl => params[:surl] })
      @trim_url = TrimUrl.first(:conditions => { :shortened_id => @shortening.id }, :include => [ :shortening ])
      @stats_ok = true if owns_trim?(@trim_url.id) 
    end
    return true
  end
  def set_permission_with_reference
    @stats_ok = false
    if TrimUrl.exists?({ :reference => params[:reference] })
      @trim_url = TrimUrl.first(:conditions => { :reference => params[:reference] }, :include => [ :shortening ])
      @stats_ok = true
    end
    return true
  end
  def set_titles
    @stats_url = "#{@trim_url.shortening.url_destination.url[0,99]}[...]" if @stats_ok
  end
  def set_summaries
    @clicks_report = ClicksReport.new(@trim_url.id, ClicksReport::SITE_TRIM, ClicksReport::ASPECT_SUMMARIES) if @stats_ok
  end
  def set_statistics_resets
    @statistics_resets  = "Element.removeClassName('subtab_summary', 'nav_current');"
    @statistics_resets << "Element.removeClassName('subtab_timelines', 'nav_current');"
    @statistics_resets << "Element.removeClassName('subtab_referers', 'nav_current');"
    @statistics_resets << "Element.removeClassName('subtab_agents', 'nav_current');"
    @statistics_resets << "Element.removeClassName('subtab_locations', 'nav_current');"
    @statistics_resets << "Element.removeClassName('subtab_shares', 'nav_current');"
  end
end
