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

class One::UrlController < ApplicationController
  before_filter :set_tlds, :only => [ :trim_url, :trim_simple ]
  skip_filter   :api_valid_format?, :only => [ :trim_simple ]

  def trim_url
    ## The process for tr.imming of a URL is basically the same as the website process. We relay on the Trimmer methods
    ## to the do the heavy lifting, but we pass in a user account if it is available for it to the attachment for us,
    ## and check for an existing URL from the same user account.
    ##
    ## The main difference is that we have to manage the appropriate return code and message, and overriding as we go if
    ## the situation changes.

    if has_parameters?(params, %w(sandbox))
      api_set_response_for_code(200)
      set_fake_trim

    else
      if api_permitted?(@api_method.id, @remote_ip)
        if has_parameters?(params, %w(url))
          if params[:url].length > UrlDestination::MINIMUM_URL_LENGTH

            @trimmer = Trimmer.new(:urls => Trimmer.prepare_destination_url(params[:url]))
            ttrim = TrimUrl.new
            ttrim[:custom] = params[:custom] if has_parameters?(params, %w(custom))
            ttrim[:privacy] = params[:privacycode] if has_parameters?(params, %w(privacycode))
            ttrim[:searchtags] = params[:searchtags] if has_parameters?(params, %w(searchtags))
            if ttrim.valid?
            
              @trimmer.token = TrimObject.get_random_code(48)
              @trimmer.url_return_id = UrlReturn::REDIRECT
              @trimmer.url_origin_id = UrlOrigin::API
              @trimmer.custom = ttrim.custom
              @trimmer.privacy = ttrim.privacy
              @trimmer.searchtags = ttrim.searchtags
              @trimmer.user_id = @user.id if has_api_session?
              @trimmer.force_new = true if has_parameters?(params, %w(newtrim))
              begin
                @trim_url = @trimmer.create_trim_url
              rescue DomainErrorTooShort
                api_set_error_response(401)
              rescue DomainErrorBadSyntax
                api_set_error_response(401)
              rescue DomainErrorShortener
                api_set_error_response(402)
              rescue DomainErrorSpam
                api_set_error_response(403)
              rescue DomainErrorCustomInuse
                api_set_error_response(404)
              else
                if @trim_url
                  set_activity("TRIM_URL")
                  if has_api_session?
                    if @trimmer.trim_url_was_new?
                      api_set_response("OK", 200, "tr.im URL Added. Attached to tr.im Account [#{@user.login}]") 
                    else
                      api_set_response("OK", 201, "tr.im URL Already Added for Authenticated tr.im Account [#{@user.login}].") end
                  else
                    if @attempted_authentication
                      api_set_response("OK", 205, "tr.im URL Added but NOT attached. Confirm Username/Password.")
                    else
                      api_set_response("OK", 200, "tr.im URL Added.") end
                  end
                  set_trim(@trim_url)
                else api_set_error_response(450) end
              end
            else
              if ttrim.errors.on "privaycode"
                api_set_error_response(406)
              elsif ttrim.errors.on "searchtags"
                api_set_error_response(407)
              else
                api_set_error_response(405) end
            end

          else api_set_error_response(401) end
        else api_set_error_response(400) end
      else api_set_error_response(425) end
    end
    set_final_response
  end
  def trim_simple
    if has_parameters?(params, %w(sandbox))
      set_fake_trim

    else
      nourl = true
      if api_permitted?(@api_method.id, @remote_ip)
        if has_parameters?(params, %w(url))
          if params[:url].length > UrlDestination::MINIMUM_URL_LENGTH

            @trimmer = Trimmer.new(:urls => Trimmer.prepare_destination_url(params[:url]))
            ttrim = TrimUrl.new
            ttrim[:custom] = params[:custom] if has_parameters?(params, %w(custom))
            ttrim[:privacy] = params[:privacycode] if has_parameters?(params, %w(privacycode))
            ttrim[:searchtags] = params[:searchtags] if has_parameters?(params, %w(searchtags))
            if ttrim.valid?
              @trimmer.token = TrimObject.get_random_code(48)
              @trimmer.url_return_id = UrlReturn::REDIRECT
              @trimmer.url_origin_id = UrlOrigin::API
              @trimmer.custom = ttrim.custom
              @trimmer.privacy = ttrim.privacy
              @trimmer.searchtags = ttrim.searchtags
              @trimmer.user_id = @user.id if has_api_session?
              @trimmer.force_new = true if has_parameters?(params, %w(newtrim))
              begin
                @trim_url = @trimmer.create_trim_url
              rescue DomainErrorTooShort
                logger.info "trim_simple URL FAILED [Domain TOO Short]"
              rescue DomainErrorBadSyntax
                logger.info "trim_simple URL FAILED [Domain BAD Syntax]"
              rescue DomainErrorShortener
                logger.info "trim_simple URL FAILED [Domain CONTAINER Shortener]"
              rescue DomainErrorSpam
                logger.info "trim_simple URL FAILED [Domain CONTAINS Spam Domain]"
              rescue DomainErrorCustomInuse
                logger.info "trim_simple URL FAILED [Domain Custom in Use]"
              else
                if @trim_url
                  set_activity("TRIM_URL")
                  set_trim(@trim_url)
                  nourl = false
                  render :layout => false
                end
              end

            end
          end
        end
      end

      if nourl
        if api_http_reject?
          render :nothing => true, :status => "403"
        else render :nothing => true end
      end
    end
  end
  
  def trim_reference
    if api_permitted?(@api_method.id, @remote_ip)
      if has_api_session?
        if has_parameters?(params, %w(trimpath))

          if UrlShortening.exists?({ :shortener_id => UrlShortener::ID_TRIM, :surl => params[:trimpath] })
            shortening = UrlShortening.first(:conditions => { :shortener_id => UrlShortener::ID_TRIM, :surl => params[:trimpath] },
                                             :include => [ :trim_url ])
            if TrimUserUrl.exists?({ :user_id => @user.id, :trim_url_id => shortening.trim_url.id })

              api_set_response("OK", 200, "tr.im URL Reference Code Returned.")
              @api["reference"] = shortening.trim_url.reference

            else api_set_error_response(410) end
          else api_set_error_response(413) end

        else api_set_error_response(413) end
      else api_set_error_response(410) end
    else api_set_error_response(425) end
    set_final_response
  end

  def trim_destination
    if api_permitted?(@api_method.id, @remote_ip)
      if has_api_session?
        if has_parameters?(params, %w(trimpath))

          trimpath = Iconv.iconv('ascii//translit', 'utf-8', params[:trimpath]).to_s.rstrip
          trimpath.delete! ".", ",", ";"
          logger.info "ICONVERTED tr.im PATH for SQL: '#{trimpath}'"

          conditions = { :shortener_id => UrlShortener::ID_TRIM, :surl => trimpath.to_s }
          if UrlShortening.exists?(conditions)

            shortening = UrlShortening.first(:conditions => conditions, :include => [ :url_destination ])
            api_set_response("OK", 200, "tr.im URL Destination URL Returned.")
            @api["destination"] = shortening.url_destination.url
            
          else api_set_error_response(414) end

        else api_set_error_response(413) end
      else api_set_error_response(410) end
    else api_set_error_response(425) end
    set_final_response
  end

  def trim_claim
    if api_permitted?(@api_method.id, @remote_ip)
      if has_api_session?
        if has_parameters?(params, %w(reference))
          if TrimUrl.exists?({ :reference => params[:reference] })

            trim_url = TrimUrl.first(:conditions => { :reference => params[:reference] })
            if TrimUserUrl.exists?({ :trim_url_id => trim_url.id })
              api_set_error_response(415) 
            else
              TrimUserUrl.create!(:user_id => @user.id, :trim_url_id => trim_url.id)
              api_set_response("OK", 200, "Referenced URL Successfully Claimed.") end

          else api_set_error_response(412) end
        else api_set_error_response(411) end
      else api_set_error_response(410) end
    else api_set_error_response(425) end
    set_final_response
  end
  
  protected
  def set_trim(trim_url)
    if trim_url.custom && trim_url.custom.length >= 1
      @api["url"] = "http://tr.im/#{trim_url.custom}"
    else
      @api["url"] = "http://tr.im/#{trim_url.shortening.surl}"
    end
    @api["reference"] = trim_url.reference
    @api["domain"] = trim_url.shortening.url_destination.domain(@tlds)
    @api["destination"] = trim_url.shortening.url_destination.url
    @api["trimpath"] = trim_url.shortening.surl
    @api["trim_path"] = trim_url.shortening.surl
    @api["visits"] = 0
    @api["trimmed"] = trim_url.created_at.to_s(:trimmed_us)
    @api["date_time"] = trim_url.created_at
    if trim_url.has_clicks?
      @api["last_visit"] = TrimClick.first(:conditions => { :trim_url_id => trim_url.id }, :order => "id DESC").created_at
      @api["last_visit_inwords"] = get_timeago_inwords(@api["last_visit"])
    end
  end
  def set_fake_trim
    @api["url"] = "http://tr.im/AbCd"
    @api["reference"] = "AbCdEfGhIjKlMnOpQrStUvXyZ"
    @api["domain"] = "destinationdomain.com"
    @api["destination"] = "http://destinationdomain.com/submittedqs"
    @api["trimpath"] = "AbCd"
    @api["trim_path"] = "AbCd"
    @api["visits"] = 0
    @api["trimmed"] = DateTime.now.to_s(:trimmed_us)
    @api["date_time"] = DateTime.now
  end
end
