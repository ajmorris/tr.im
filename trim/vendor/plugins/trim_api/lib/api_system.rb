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

require 'api_limit'
require 'api_method'

module ApiSystem
  protected
  def has_parameters?(collection, needed)
    return false unless collection.is_a?(Hash) && needed.is_a?(Array)
    needed.each do |n|
      return false unless n.is_a? String
      return false unless collection.has_key?(n) && collection[n].is_a?(String)
    end
    return true
  end
  def has_one_of_parameters?(collection, needed)
    return false unless collection.is_a?(Hash) && needed.is_a?(Array)
    needed.each do |n|
      return false unless n.is_a? String
      return true if collection.has_key?(n) && collection[n].is_a?(String)
    end
    return false
  end
  

  ## Common methods for API initializatiom, setup, standard response variable, and a JSON wrapper for the standard
  ## response variable.

  def api_initialize
    @attempted_authentication = false
    @api_http_reject = false

    api_set_response
    api_authenticate
  end
  def api_initialize_for_upload
    @attempted_authentication = false
    @api_http_reject = false
  end

  def api_user_agent
    if request.user_agent.blank?
      RAILS_DEFAULT_LOGGER.info "UA NOT Submitted to API"
    else
      RAILS_DEFAULT_LOGGER.info "UA Submitted to API [#{request.user_agent}]" end
  end

  def set_api_method
    @api_method = @api_methods.detect {|m| m.name == params[:action] }
  end  
  def set_api_methods
    @api_limits  = Rails.cache.fetch("api_limits",  :expires_in => 2.hours) { ApiLimit.all }
    @api_methods = Rails.cache.fetch("api_methods", :expires_in => 2.hours) { ApiMethod.all }
  end

  
  ## These methods tell you whether or not the API key submitted is defined, and whether it is set to bypass
  ## all API limits.
  
  def api_valid_format?
    return true if params.has_key?("format") && (params[:format].downcase == "json" || params[:format].downcase == "xml")
    api_set_error_response(449)
    render :json => @api.to_json
    return false
  end
  def api_http_reject?
    @api_http_reject
  end

  def api_valid_key?
    ApiKey.exists?({ :api_key => get_api_key })
  end
  def api_bypass_key?
    ApiKey.exists?({ :api_key => get_api_key, :bypass => ApiKey::BYPASS_YES })
  end


  def api_set_response(status = "OK", code = 200, message = "Request Completed")
    @api = Hash.new unless @api && @api.is_a?(Hash)
    @api["status"] = { "result" => status, "code" => code.to_s, "message" => message }
  end
  def api_set_response_for_code(code)
    raise ArgumentError unless @@api_response_codes.has_key?(code)
    @api["status"] = { "result" => "OK", "code" => code.to_s, "message" => @@api_response_codes[code] }
  end

  def api_set_response_json(callback)
    return "#{callback.tr("()", "")}(#{@api_response.to_json})" unless callback.blank?
    return @api.to_json
  end
  def api_set_error_response(code, message = nil)
    raise ArgumentError unless @@api_response_codes.has_key?(code)
    @api["status"] = { "result" => "ERROR", "code" => code.to_s, "message" => message }
    @api["status"]["message"] = @@api_response_codes[code] if message == nil
  end


  ## This method will process any API authentication that is submitted based on the method calling for it. 
  ## Supports HTTP, parameters and Nambu Unique ID and is going for an @user object, starting from scratch
  ## if you call this method.
  ##
  ## For authentication we always return true so that the API call can continue if the authorization attempts fails.
  ## We will accept either if they succeed, but go with HTTP Basic as the overriding method if both are present.

  def api_authenticate
    @user = nil
    if has_parameters?(params, %w(username password))
      @attempted_authentication = true
      if User.exists?({ :login => params[:username].downcase, :password => params[:password] })
        @user = User.first(:conditions => { :login => params[:username].downcase, :password => params[:password] })      
      end
    end
    if request.env.has_key? 'HTTP_AUTHORIZATION'
      if request.env['HTTP_AUTHORIZATION'].start_with?("Basic")
        logger.info "Basic Authentication Attempt Detected: BASIC HTTP as Priority Method"
        authenticate_or_request_with_http_basic do |username, password|
          @attempted_authentication = true
          if User.exists?({ :login => username.downcase, :password => password })
            @user = User.first(:conditions => { :login => username.downcase, :password => password })
          end
        end
      end
    end
    return true
  end
  def has_api_session?
    @user && @user.is_a?(User)
  end


  ## Checks whether the caller is still within their limit for the given method. This method will record the API
  ## hit so that the caller does not have to worry about it. So, checking your API status records a hit unless we
  ## are told not to.
  ##
  ## This API rate limiting implementation is average. It resets at the top of the hour, not a rolling time
  ## period as most other APIs work.
  
  def api_permitted?(method_id, ip_address, record_hit = true)
    api_record_hit(method_id, ip_address) if record_hit
    api_limit = @api_limits.detect {|limit| limit.method_id == method_id }  

    if has_one_of_parameters?(params, %w(api_key apiKey)) && api_bypass_key?
      return true
    else
      if api_hits = ApiHits.first(:conditions => { :method_id => method_id, :ip_address => ip_address, :day => get_apid, :hour => get_apih })
        api_ch = api_hits.count
        api_cd = ApiHits.sum(:count, :conditions => { :method_id => method_id, :ip_address => ip_address, :day => get_apid })
      else api_ch, api_cd = 0, 0 end

      return true if api_ch <= api_limit.hour && api_cd <= api_limit.day

      override, override_hour, override_day = false, api_limit.hour, api_limit.day
      override, override_hour, override_day = api_key_has_override?(method_id) if has_one_of_parameters?(params, %w(api_key apiKey))
      if override
        if api_ch <= override_hour
          if api_cd <= override_day
            return true
          else logger.info "OVERRIDE API Rate Limit [DAY:#{override_day}] Exceeded for Method [#{method_id}] [#{ip_address}]." end
        else logger.info "OVERRIDE API Rate Limit [HOUR:#{override_hour}] Exceeded for Method [#{method_id}] [#{ip_address}]." end
        if (api_ch * ApiLimit::STATUS_HTTP_MULTIPLE) > override_hour || (api_cd * ApiLimit::STATUS_HTTP_MULTIPLE) > override_day
          @api_http_reject = true
        end
      else
        logger.info "STANDARD API Rate Limit [DAY] Exceeded for Method [#{method_id}] [#{ip_address}]." if api_ch > api_limit.hour
        logger.info "STANDARD API Rate Limit [HOUR] Exceeded for Method [#{method_id}] [#{ip_address}]." if api_cd > api_limit.day
        if (api_ch * ApiLimit::STATUS_HTTP_MULTIPLE) > api_limit.hour || (api_cd * ApiLimit::STATUS_HTTP_MULTIPLE) > api_limit.day
          @api_http_reject = true
        end
      end
    end
    return false
  end

  def api_record_hit(method_id, ip_address)
    attempts, maximum = 0, 5
    loop do
      begin

        ApiHits.transaction do
          conditions = { :method_id => method_id, :ip_address => ip_address, :day => get_apid, :hour => get_apih }
          if api_hits = ApiHits.first(:conditions => conditions)
            api_hits[:count] += 1
          else
            api_hits = ApiHits.new(:method_id => method_id, :ip_address => ip_address)
            api_hits[:day] = get_apid
            api_hits[:hour] = get_apih
            api_hits[:count] = 1
          end
          api_hits.save          
        end
        break
        
      rescue ActiveRecord::StatementInvalid
        logger.info "INSERTION Failure on HITS COUNT UPDATE. Duplicate Alreay Entered?"
        attempts += 1
        break if attempts > maximum

      rescue ActiveRecord::StaleObjectError
        logger.info "STALE OBJECT Failure on HITS COUNT UPDATE. RETRYING."
        attempts += 1
        break if attempts > maximum
      end
    end
    

    if has_one_of_parameters?(params, %w(api_key apiKey)) && api_valid_key?
      attempts, maximum = 0, 5
      loop do
        begin

          ApiHitsKey.transaction do
            api_key = ApiKey.first(:conditions => { :api_key => get_api_key })
            if ApiHitsKey.exists?({ :method_id => method_id, :api_key_id => api_key.id, :day => get_apid, :hour => get_apih })
              api_hits_k = ApiHitsKey.first(:conditions => { :method_id => method_id,
                                                             :api_key_id => api_key.id, :day => get_apid, :hour => get_apih })
              api_hits_k.count += 1
            else
              api_hits_k = ApiHitsKey.new(:method_id => method_id, :api_key_id => api_key.id)
              api_hits_k[:day] = get_apid
              api_hits_k[:hour] = get_apih
              api_hits_k[:count] = 1
            end
            api_hits_k.save
          end
          break
          
        rescue ActiveRecord::StatementInvalid
          logger.info "INSERTION Failure on HITS COUNT UPDATE [FOR KEY]. Duplicate Alreay Entered?"
          attempts += 1
          break if attempts > maximum
          
        rescue ActiveRecord::StaleObjectError
          logger.info "STALE OBJECT Failure on HITS COUNT UPDATE [FOR KEY]. RETRYING."
          attempts += 1
          break if attempts > maximum
        end
      end
    end
  end
  
  private
  def api_key_has_override?(method_id)                             ## Returns true/false, override_hour, override_day
    keyobject = ApiKey.first(:conditions => { :api_key => get_api_key })
    override  = ApiOverride.first(:conditions => { :api_key_id => keyobject.id, :method_id => method_id })
    return true, override.hour, override.day if override
    return false, 0, 0
  end

  def get_apid
    DateTime.now.to_date
  end
  def get_apih
    DateTime.now.strftime("%H")
  end
  def get_api_key
    return params[:api_key] if params.has_key?("api_key")
    return params[:apiKey]  if params.has_key?("apiKey")
    return nil
  end
  
  @@api_response_codes = {
    200 => "Request Completed. tr.im URL Added, if Applicable",
    201 => "Request Completed. tr.im URL Already Added for Session or Authenticated tr.im Account",
    202 => "Request Completed. tr.im URL Added and Attached to Authenticated tr.im Account",
    205 => "Request Completed. tr.im URL Added but NOT attached. Confirm Username/Password",
    400 => "Required Parameter URL Not Submitted",
    401 => "Submitted URL Invalid",
    402 => "Submitted URL is Already a Shortened URL",
    403 => "The URL has been Flagged as Spam and Rejected",
    404 => "The Custom tr.im URL Requested is Already in Use",
    405 => "Requested Custom URL Contains Invalid Characters",
    406 => "Requested Privacy Code Contains Invalid Characters",
    407 => "Requested Search Tags Contains Invalid Characters",
    410 => "Required Authentication Not Submitted or Invalid",
    411 => "URL Reference Code Not Submitted",
    412 => "URL Reference Code Not Does Not Exist",
    413 => "tr.im URL Path Not Submitted",
    414 => "tr.im URL Does Not Exist",
    415 => "tr.im URL Already Claimed",
    420 => "Media Type Uploaded Not Supported",
    421 => "Media Uploaded too Large",
    422 => "Media Uploaded XY Dimensions too Small",
    425 => "API Rate Limit Exceeded",
    426 => "API Key Submitted Does Not Exist or is Invalid",
    427 => "API Key Required",
    445 => "Parameter Data Within the Request is Invalid",
    446 => "Required Parameter Missing within the Request",
    447 => "Username Requested is In Use",
    449 => "Invalid Response Format Requested",
    450 => "An Unknown Error Occurred. Please Email api@tr.im"
  }
end
