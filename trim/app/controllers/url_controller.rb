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

class UrlController < ApplicationController
  before_filter :ajax?
  before_filter :set_menu_resets, :only => [ :create ]
  before_filter :get_trimform_reset, :only => [ :create ]
  before_filter :set_tlds, :only => [ :create, :search ]
  before_filter :set_marklet, :only => [ :create ]
  before_filter :set_oauths, :only => [ :create, :share ]
  before_filter :set_url_search, :only => [ :search ]
  before_filter :set_url_returns, :only => [ :create, :search ]

  def create
    if params.has_key?("trim") && params[:trim].is_a?(Hash) && params[:trim][:url].length > UrlDestination::MINIMUM_URL_LENGTH
      @trimmer = Trimmer.new(:urls => Trimmer.prepare_destination_url(params[:trim][:url]))
      @user_url = @trimmer.urls
      @trim_url = nil
      logger.info "USER URL SUBMITTED [#{@user_url}]"

      ## We use the rails model to screen the options data to see if it passes basic checks.
      ttrim = TrimUrl.new
      ttrim.custom = params[:options][:custom] if has_parameters?(params[:options], %w(custom))
      ttrim.privacy = params[:options][:privacy] if has_parameters?(params[:options], %w(privacy))
      if not ttrim.valid?
        render :partial => "create_options", :locals => { :errors => ttrim.errors }
      else
        logger.info "ACTIVITY COUNT: #{get_activity_count("TRIM_URL", 1.hour.ago)}"
        if get_activity_count("TRIM_URL", 1.hour.ago) < TrimAction::TRIMS_MAX_PER_HOUR

          @trimmer.token = request.session_options[:id]
          @trimmer.url_return_id = UrlReturn::REDIRECT
          @trimmer.url_origin_id = UrlOrigin::TRIM
          @trimmer.custom = ttrim.custom
          @trimmer.privacy = ttrim.privacy
          @trimmer.searchtags = ttrim.searchtags
          @trimmer.user_id = @user.id if has_session?
          begin
            @trim_url = @trimmer.create_trim_url

          rescue DomainErrorTooShort
            render :partial => "create_invalid", :locals => { :error_text => t(:url_invalid, :scope => :errors) }
          rescue DomainErrorBadSyntax
            render :partial => "create_invalid", :locals => { :error_text => t(:url_invalid, :scope => :errors) }
          rescue DomainErrorShortener
            render :partial => "create_invalid", :locals => { :error_text => t(:url_other, :scope => :errors) }
          rescue DomainErrorSpam
            render :partial => "create_invalid", :locals => { :error_text => t(:url_spam, :scope => :errors) }
          rescue DomainErrorCustomInuse
            render :partial => "create_reserved", :locals => { :error_text => t(:url_customused, :scope => :errors) }

          else
            if @trim_url

              if @trimmer.trim_url_was_new?
                flash.now[:notice] = t(:url_new, :scope => :notices)
                set_activity("TRIM_URL")
                add_trim_to_session(@trim_url.id) unless has_session?
              else
                flash.now[:notice] = t(:url_already, :scope => :notices) end

              if params[:trim_preferences][:trimtweet] == "YES"
                render :partial => "create_share"
              else
                render :partial => "create" end

            else
              render :partial => "create_invalid", :locals => { :error_text => t(:url_unknown, :scope => :errors) } end
          end

        else
          render :partial => "create_invalid", :locals => { :error_text => t(:url_limit, :scope => :errors) } end
      end
    else
      render :partial => "create_nourl", :locals => { :error_text => t(:url_nodata, :scope => :errors) } end
  end
  
  def update
    if TrimUrl.exists?(params[:id])

      @trim_url = TrimUrl.find(params[:id])
      if owns_trim?(@trim_url.id)
        @trim_url.update_attributes(params[:trim_url])
        @trim_url.save!
        render :partial => "update"
      else
        render :partial => "update_noauth" end

    else
      logger.info "Attempt to UPDATE Non-existent tr.im URL! [#{params[:id]}]"
      render :partial => "shared/rjs/redirect" end
  end

  def destroy
    if TrimUrl.exists?(params[:id])
      @trim_url = TrimUrl.find(params[:id])
      if owns_trim?(@trim_url.id)
        
        if @trim_url.clicks > TrimUrl::DELETION_NEEDED
          @trim_url[:deletion] = TrimUrl::DELETION_YES
          @trim_url.save
          logger.info "TrimUrl MARKED FOR DELETION [#{@trim_url.id}]"
        else
          @trim_url.destroy end

        render :partial => "destroy"

      else
        render :partial => "destroy_noauth" end
    else
      logger.info "Attempt to DELETE Non-existent tr.im URL! [#{params[:id]}]"
      render :partial => "shared/rjs/redirect" end
  end


  def reset
    if TrimUrl.exists?(params[:id])
      @trim_url = TrimUrl.find(params[:id])
      if owns_trim?(@trim_url.id)

        if @trim_url.clicks > TrimUrl::DELETION_NEEDED
          @trim_url[:reset] = TrimUrl::RESET_YES
          @trim_url.save
          render :partial => "reset_soon"
          logger.info "TrimUrl MARKED FOR RESET [#{@trim_url.id}]"
        else
          trim_url.reset_stats!
          render :partial => "reset"
        end
        
      else
        render :partial => "reset_noauth" end
    else
      logger.info "Attempt to RESET Non-existent tr.im URL! [#{params[:id]}]"
      render :partial => "shared/rjs/redirect" end
  end

  
  def search
    set_trims_with_search(@url_search_term.downcase.split(/ /)) unless @url_search_term.blank?
  end
  def share
    if TrimUrl.exists?(params[:trim_url][:id])
      @trim_url = TrimUrl.find(params[:trim_url][:id])
      render :partial => "share"
    else
      logger.info "Attempt to SHARE Non-existent tr.im URL! [#{params[:trim_url][:id]}]"
      render :partial => "shared/rjs/redirect" end
  end
  
  private
  def set_url_search
    @url_search_term = String.new if params[:q].blank?
    @url_search_term = params[:q].rstrip unless params[:q].blank?
  end
end
