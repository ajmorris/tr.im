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
# These two methods still need to be overhauled to emulate the apiKey as the user password, and make the necessary changes
# with the API module to accomodate user api keys, which tr.im does not use, currently.
##

class One::BitlyController < ApplicationController
  before_filter :set_tlds, :only => [ :shorten ]
  skip_filter   :api_valid_format?

  def shorten
    if api_permitted?(@api_method.id, @remote_ip)
      if has_parameters?(params, %w(longUrl))                       ## Short ones are ok too?
        if params[:longUrl].length > UrlDestination::MINIMUM_URL_LENGTH

          @trimmer = Trimmer.new(:urls => Trimmer.prepare_destination_url(params[:longUrl]))            
          @trimmer.token = TrimObject.get_random_code(48)
          @trimmer.url_return_id = UrlReturn::REDIRECT
          @trimmer.url_origin_id = UrlOrigin::API
          @trimmer.user_id = @user.id if has_api_session?
          begin
            @trim_url = @trimmer.create_trim_url

          rescue DomainErrorTooShort, DomainErrorBadSyntax, DomainErrorShortener, DomainErrorSpam, DomainErrorCustomInuse
            set_bitly_error_resonse

          else
            if @trim_url
              set_activity("TRIM_URL")
              set_bitly_shorten_response
            else
              set_bitly_error_resonse end end

        else set_bitly_error_resonse end
      else set_bitly_error_resonse end
    else set_bitly_error_resonse end
    render :json => @api.to_json
  end
  

  def expand                                                        ## bit.ly has versioned this method with a verison= parameter, which is pretty
    if api_permitted?(@api_method.id, @remote_ip)                   ## amateur. This means we cant emulate this method with any certainty. API
      if has_parameters?(params, %w(shortUrl))                      ## methods *should* be versioned by the path name: /v2/expand, for example.

        trimpath = Iconv.iconv('ascii//translit', 'utf-8', params[:shortUrl]).to_s.rstrip
        trimpath.delete! ".", ",", ";"
        logger.info "ICONVERTED tr.im PATH for SQL: '#{trimpath}'"

        conditions = { :shortener_id => UrlShortener::ID_TRIM, :surl => trimpath.to_s }
        if UrlShortening.exists?(conditions)

          @shortening = UrlShortening.first(:conditions => conditions, :include => [ :url_destination ])
          set_bitly_expand_response
          
        else set_bitly_error_resonse end

      else set_bitly_error_resonse end
    else set_bitly_error_resonse end
    render :json => @api.to_json
  end
  
  protected
  ##
  # bit.ly Examples:
  #   { "errorCode": 101, "errorMessage": "Unknown error", "statusCode": "ERROR" }
  #   { "errorCode": 0, "errorMessage": "", "statusCode": "OK", "results":
  #     {
  #       "http://cnn.com": { "hash": "31IqMl", "shortKeywordUrl": "", "shortUrl": "http://bit.ly/15DlK", "userHash": "15DlK" }
  #     }
  #   }
  #   { "errorCode": 0, "errorMessage": "", "results": { "31IqMl": { "longUrl": "http://cnn.com/" } }, "statusCode": "OK" }
  ##

  def set_bitly_shorten_response
    @api = {
      "errorCode" => 0, "errorMessage" => "",
      "results" => {
        @trim_url.shortening.url_destination.url => {
          "hash" => @trim_url.shortening.surl,
          "shortKeywordUrl" => "",                                          ## I dont know what this is intended to be
          "shortUrl" => "http://tr.im/#{@trim_url.shortening.surl}",
          "userHash" => ""                                                  ## I dont know what this is intended to be
        }
      },
      "statusCode" => "OK"
    }
  end
  def set_bitly_expand_response
    @api = {
      "errorCode" => 0, "errorMessage" => "", 
      "results" => {
        @shortening.surl => { "longUrl" => @shortening.url_destination.url }
      },
      "statusCode" => "OK"
    }
  end
  def set_bitly_error_resonse
    @api = {                                                                ## Always 101.       
      "errorCode" => 101, "statusCode" => "ERROR",
      "errorMessage" => "ERROR. Reconfirm everything and try again. We don't emulate bit.ly's error codes. SORRY!"
    }         
  end
end
