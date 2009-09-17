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

class RedirectController < ApplicationController
  def index
    ## Users have the option to attaching a privacy code or other options after the tr.im URL. We need to strip this off to
    ## get to the tr.im URL portion which lets us find it.

    @url_extra = String.new
    if params[:trim_url].include?("-")
      url_items = params[:trim_url].split(/-/)
      urls = url_items[0]
      @url_extra = url_items[1] unless url_items.empty?
    else
      urls = params[:trim_url]
      urls.chop! if urls.end_with?(",") || urls.end_with?(".") || urls.end_with?(")") || urls.end_with?("]")
    end

    begin
      cvurls = Iconv.iconv('ascii//translit', 'utf-8', urls).to_s
      cvurls.gsub(/\W/, '')

      if UrlShortening.exists?({ :shortener_id => UrlShortener::ID_TRIM, :surl => cvurls })
        @shortening = UrlShortening.first(:conditions => { :shortener_id => UrlShortener::ID_TRIM, :surl => cvurls },
                                          :include => [ :trim_url, :url_destination ])
        @trim_url = @shortening.trim_url
        do_redirection

      elsif TrimUrl.exists?({ :custom => cvurls.downcase })
        @trim_url = TrimUrl.first(:conditions => { :custom => cvurls.downcase }, :include => [ :shortening ])
        @shortening = UrlShortening.find(@trim_url.shortened_id, :include => [ :url_destination ])
        do_redirection

      else
        logger.info "FAILED REDIRECT: No such URL (as submitted #{params[:trim_url]}) ..."
        final_redirect(WEBSITE_CONFIG['nourl_url']) end

    rescue Iconv::InvalidCharacter
      puts "FAILED REDIRECT: ICONV Failure on INVALID CHARACTER [#{urls}]"
      final_redirect(WEBSITE_CONFIG['nourl_url'])

    rescue Iconv::IllegalSequence
      puts "FAILED REDIRECT: ICONV Failure on INVALID PATH [#{urls}]"
      final_redirect(WEBSITE_CONFIG['nourl_url']) end
  end

  private
  def do_redirection
    case @trim_url.return_id
    when UrlReturn::REDIRECT

      if @trim_url.has_privacy? && (not @trim_url.privacy == @url_extra)
        logger.info "FAILED REDIRECT: Privacy Code REQUIRED [#{@shortening.surl}]"
        final_redirect(WEBSITE_CONFIG['private_url'])

      else
        if request.method == :get
          spawn do                                          ## Carry on click record and location determinations in a 
            ipl = IPLocator.new(:ip_address => @remote_ip)  ## thread that continues on as needed after we issue redirect.
            TrimClick.transaction do
              @trim_click = TrimClick.new(:trim_url_id => @trim_url.id)
              @trim_click[:country_id] = ipl.country_id
              @trim_click[:region_id] = ipl.region_id
              @trim_click[:city_id] = ipl.city_id
              @trim_click[:agent_id] = @user_agent.id
              @trim_click[:ip_address] = @remote_ip
              @trim_click[:session_id] = "NONE"
              @trim_click[:referer] = request.referer unless request.referer.blank?
              @trim_click.save!
              ## logger.info "REDIRECT REFERER [#{request.referer}]"
            end

            @trim_url[:clicks] = TrimClick.count('trim_url_id', :conditions => "trim_url_id = #{@trim_url.id}")
            @trim_url.save(false)
            ## logger.info "Clicks SET #{trim_url.id}] => #{@trim_url.clicks}"
          end
        else
          logger.info "NON-GET REQUEST Detected. No CLICK Recorded." end

        final_redirect(@shortening.url_destination.url)
      end

    when UrlReturn::SPAM
      redirect_to WEBSITE_CONFIG['spam_url']

    else
      logger.info "Unknown RETURN TYPE? [#{@trim_url.return_id}]. REDIRECTED to #{root_url}"
      final_redirect(root_url) end
  end
  def final_redirect(dest_url)
    redirect_to dest_url, :status => 301
  end
end

