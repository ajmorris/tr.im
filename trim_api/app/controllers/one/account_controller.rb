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

class One::AccountController < ApplicationController
  before_filter :api_valid_key?, :except => [ :verify ]
  before_filter :set_tlds, :only => [ :account_urls ]

  def verify
    if api_permitted?(@api_method.id, @remote_ip)
      if has_api_session?

        api_set_response("OK", 200, "User Account/Password Verified.")

      else api_set_error_response(410) end
    else api_set_error_response(425) end
    set_final_response
  end

  def account_urls
    if api_permitted?(@api_method.id, @remote_ip)
      if has_api_session?

        api_set_response("OK", 200, "tr.im Account URLs Returned.")
        i, summary = 0, Array.new
        uurls = TrimUserUrl.all(:conditions => { :user_id => @user.id }, :order => "id DESC", :limit => get_rc, :include => [ :trim_url ])
        for trim_user_url in uurls
          summary << {
            "url" => "http://tr.im/#{trim_user_url.trim_url.shortening.surl}",
            "reference" => trim_user_url.trim_url.reference,
            "domain" => trim_user_url.trim_url.shortening.url_destination.domain(@tlds),
            "destination" => trim_user_url.trim_url.shortening.url_destination.url,
            "trimpath" => trim_user_url.trim_url.shortening.surl,
            "trim_path" => trim_user_url.trim_url.shortening.surl,
            "visits" => trim_user_url.trim_url.clicks_count,
            "trimmed" => trim_user_url.trim_url.created_at.to_s(:trimmed_us),
            "date_time" => trim_user_url.trim_url.created_at
          }
          if trim_user_url.trim_url.has_clicks?
            last_click_dt = TrimClick.first(:conditions => { :trim_url_id => trim_user_url.trim_url.id }, :order => "id DESC").created_at
            summary[i]["visits_since"] = trim_user_url.trim_url.clicks_since(params[:visits_since].to_i) unless params[:visits_since].blank?
            summary[i]["last_visit"] = last_click_dt
            summary[i]["last_visit_i"] = summary[i]["last_visit"].to_i
            summary[i]["last_visit_inwords"] = get_timeago_inwords(last_click_dt)
          end
          i += 1
        end
        @api["urls"] = summary unless i == 0
        @api["url_count"] = i

      else api_set_error_response(410) end
    else api_set_error_response(425) end
    set_final_response
  end
  
  def account_visits
    if api_permitted?(@api_method.id, @remote_ip)
      if has_api_session?
    
        api_set_response("OK", 200, "tr.im Statistics Returned.")
        account_count, url_count = 0, 0
        summary = Array.new
        for trim_user_url in TrimUserUrl.all(:conditions => { :user_id => @user.id }, :order => "id DESC", :limit => get_rc)
          summary << {
            "url" => "http://tr.im/#{shortening.surl}",
            "trimpath" =>  trim_user_url.trim_url.shortening.surl,
            "trim_path" =>  trim_user_url.trim_url.shortening.surl,
            "reference" => trim_user_url.trim_url.reference,
            "total_visits" => trim_user_url.trim_url.clicks_count
          }
          if trim_user_url.trim_url.has_clicks?
            visits = Array.new
            for click in trim_user_url.trim_url.trim_clicks
              visits << {
                "date_time" => click.created_at,
                "country_code" => click.country.code
              }
            end
            summary[url_count]["visits"] = visits
          end
          url_count += 1
          account_count += trim_user_url.trim_url.clicks_count
        end
        @api["urls"] = summary unless url_count == 0
        @api["url_count"] = url_count
        @api["total_visits"] = account_count
    
      else api_set_error_response(410) end
    else api_set_error_response(425) end
    set_final_response
  end
  
  def account_ttrims
    if api_permitted?(@api_method.id, @remote_ip)
      if has_api_session?

          api_set_response("OK", 200, "Account Top tr.ims Herein")
          ## TBD

      else api_set_error_response(410) end
    else api_set_error_response(425) end
    set_final_response
  end

  def account_picims
    if api_permitted?(@api_method.id, @remote_ip)
      if has_api_session?

        api_set_response("OK", 200, "tr.im Account pic.im URLs Returned.")
        picim_count, summary = 0, Array.new
        for puu in PicimUserUrl.all(:conditions => { :user_id => @user.id }, :order => "id DESC", :limit => get_rc, :include => [ :picim_url ])
          summary << {
            "url" => "http://pic.im/#{puu.picim_url.surl}",
            "reference" => puu.picim_url.images[0].reference,
            "picimpath" => puu.picim_url.surl,
            "image_url_thumbnail" => puu.picim_url.images[0].thumbnail_url,
            "image_url_iphone" => puu.picim_url.images[0].iphone_url,
            "visits" => puu.picim_url.clicks,
            "uploaded_from" => "TBD",
            "uploaded_at" => puu.picim_url.created_at(:trimmed_us),
            "uploaded_at_date_time" => puu.picim_url.created_at,
            "uploaded_at_inwords" => get_timeago_inwords(puu.picim_url.created_at)
          }
          picim_count += 1
        end
        @api["picims"] = summary unless picim_count == 0
        @api["picims_count"] = picim_count

      else api_set_error_response(410) end
    else api_set_error_response(425) end
    set_final_response
  end
  
  protected
  def get_rc
    returns = 20
    if has_parameters?(params, %w(count))
      returns = params[:count].to_i
      returns = 1 if returns <= 0
      returns = 100 if returns > 100
    end
    return returns
  end
end
