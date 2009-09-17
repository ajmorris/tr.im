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

class MarkletController < ApplicationController
  before_filter :set_url_returns, :set_tlds, :set_oauths
  before_filter :set_marklet, :set_marklet_referer

  def index
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Bookmarklet for URL"
    @tab = "urls"
    
    if params[:url].blank?
      ## We process this again below.

    elsif (params[:url].starts_with?("http://tr.im") || params[:url].include?(".tr.im")) && (params[:url].count("/") < 4)
      flash[:notice] = t(:url_marklet_at_trim, :scope => :errors)

    else
      ## If get past the empty bookmarklet -- when a user just clicks on the draggable link -- we then process the
      ## URL as normal. From here we end up rendering the result page, or an error on the index page.

      if params[:url].length > UrlDestination::MINIMUM_URL_LENGTH
        @trimmer = Trimmer.new(:urls => Trimmer.prepare_destination_url(params[:url]))
        @user_url = @trimmer.urls
        @trim_url = nil

        logger.info "ACTIVITY COUNT: #{get_activity_count("TRIM_URL", 1.hour.ago)}"
        if get_activity_count("TRIM_URL", 1.hour.ago) < TrimAction::TRIMS_MAX_PER_HOUR
          @trimmer.token = request.session_options[:id]
          @trimmer.url_return_id = UrlReturn::REDIRECT
          @trimmer.url_origin_id = UrlOrigin::TRIM
          @trimmer.user_id = @user.id if has_session?
          begin
            @trim_url = @trimmer.create_trim_url

          rescue DomainErrorTooShort
            flash.now[:notice] = t(:url_invalid, :scope => :errors)
          rescue DomainErrorBadSyntax
            flash.now[:notice] = t(:url_invalid, :scope => :errors)
          rescue DomainErrorShortener
            flash.now[:notice] = t(:url_other, :scope => :errors)
          rescue DomainErrorSpam
            flash.now[:notice] = t(:url_spam, :scope => :errors)
          rescue DomainErrorCustomInuse
            flash.now[:notice] = t(:url_customused, :scope => :errors)

          else
            if @trim_url
              @marklet_errors = false
              if @trimmer.trim_url_was_new?
                flash.now[:notice] = t(:url_new, :scope => :notices)
                set_activity("TRIM_URL")
                add_trim_to_session(@trim_url.id) if not has_session?
              else
                flash.now[:notice] = t(:url_already, :scope => :notices) end
            else
              flash.now[:notice] = t(:url_unknown, :scope => :errors) end
          end

        else
          flash.now[:notice] = t(:url_limit, :scope => :errors) end
      else
        flash[:notice] = t(:url_nodata, :scope => :errors) end
    end

    ## For an empty URL parameter on a bookmarklet vast odds are they are not using a browser. They get a 403 
    ## get lost. Also, no user agent almost always means no browser, also, in which case, get lost.
    
    if params[:url].blank? || request.user_agent.blank?
      render :nothing => true, :status => 403
      logger.info "MARKLET ERROR: Blank URL and/or Blank User Agent [403]"

    elsif @marklet_errors
      set_trims_with_charts
      render :action => :index

    else
      if params[:option]
        case params[:option]
        when "twitter"
          redirect_to "http://twitter.com/home?status=#{get_trim_url(@trim_url)}" end
      end
    end
  end  

  private
  def set_marklet_referer
    session[:marklet_referer] = request.referer
    begin
      uri = URI.parse(request.referer)
    rescue Exception => i then return false end
    uri.host && uri.host.length > 2 ? session[:marklet_returnto] = uri.host : session[:marklet_returnto] = request.referer
  end
end
