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

require 'rubygems'
require 'net/http'
require 'uri'
require 'json'
require 'oauth'

class NCTwitterOAuth
  def initialize(key, secret, user_token, user_secret)
    @consumer = OAuth::Consumer.new(key, secret, { :site => "http://twitter.com" })    
    @access_token = OAuth::AccessToken.new(@consumer, user_token, user_secret)
    ## test_token(key, secret, user_token, user_secret)
  end
  
  ## 
  # Examples:
  #   @consumer.request(:get,  '/people', @token, { :scheme => :query_string })
  #   @consumer.request(:post, '/people', @token, {}, @person.to_xml, { 'Content-Type' => 'application/xml' })
  ##
  
  def submit_tweet(tweet_text, in_reply_to_status_id = 0)
    ## RAILS_DEFAULT_LOGGER.info "NCTwitterOAuth.submit_tweet(): SOURCE [#{@source}]"
    retcode = 200
    begin
      if in_reply_to_status_id > 0
        res = @consumer.request(:post, '/statuses/update.json', @access_token, {}, { "status" => tweet_text,
                                                                                     "in_reply_to_status_id" => in_reply_to_status_id })
      else
        res = @consumer.request(:post, '/statuses/update.json', @access_token, {}, { "status" => tweet_text }) end

      ## RAILS_DEFAULT_LOGGER.info res.body.inspect
      case res
      when Net::HTTPSuccess
        return JSON.parse(res.body) if res.code.to_i == 200
        retcode = res.code.to_i
      else
        retcode = res.code.to_i
        RAILS_DEFAULT_LOGGER.info "NCTwitterOAuth.submit_tweet(): TWITTER OAuth Failed to VERIFY?" end
    rescue Exception => e
      raise_general_exception("NCTwitterOAuth.submit_tweet()", e)
    else
      raise_nc_exception("NCTwitterOAuth.submit_tweet()", retcode) end
  end

  protected
  def test_token(key, secret, user_token, user_secret)
    RAILS_DEFAULT_LOGGER.info "TESTING THE TOKEN ..."
    RAILS_DEFAULT_LOGGER.info ".. User Token [#{user_token}]"
    RAILS_DEFAULT_LOGGER.info ".. User Secret [#{user_secret}]"
    testcons = OAuth::Consumer.new(key, secret, { :site => "http://twitter.com" })
    testtokn = OAuth::AccessToken.new(testcons, user_token, user_secret)
    response = testcons.request(:get, '/favorites.json', testtokn, { :scheme => :query_string })
    RAILS_DEFAULT_LOGGER.info ".. #{response.inspect}"
    RAILS_DEFAULT_LOGGER.info ".. #{response.body.inspect}"
  end
  def raise_nc_exception(method, code)
    case code
    when 400
      RAILS_DEFAULT_LOGGER.info "#{method}: Twitter Failure [CODE 400]"
      raise NCRateLimited
    when 401
      RAILS_DEFAULT_LOGGER.info "#{method}: Twitter Failure [CODE 401]"
      raise NCNotAuthorized
    else
      RAILS_DEFAULT_LOGGER.info "#{method}: GENERAL Twitter Failure [CODE #{code}]"
      raise NCGeneralFailure end
  end
  def raise_general_exception(method, e)
    RAILS_DEFAULT_LOGGER.info ".. #{method}: Fatal Exception Rescued [#{e.to_s}]."
    RAILS_DEFAULT_LOGGER.info e.backtrace.join("\n")
    raise NCGeneralFailure
  end
end
