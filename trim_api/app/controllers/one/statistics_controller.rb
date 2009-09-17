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

class One::StatisticsController < ApplicationController
  before_filter :api_valid_key?

  def url_visits
    if api_permitted?(@api_method.id, @remote_ip)
      if has_parameters?(params, %w(reference))
        if TrimUrl.exists?({ :reference => params[:reference] })

          api_set_response("OK", 200, "tr.im Statistics Returned.")
          visits = Array.new

          trim_url = TrimUrl.first(:conditions => { :reference => params[:reference] })
          trim_url.trim_clicks do |click|
            visits << { "datetime" => click.created_at, "country_code" => click.country.code }
          end
          @api["visits"] = visits unless trim_url.clicks_count == 0
          @api["total_visits"] = trim_url.clicks_count

        else api_set_error_response(412) end
      else api_set_error_response(411) end
    else api_set_error_response(425) end
    set_final_response
  end
  
  def url_activity
    if api_permitted?(@api_method.id, @remote_ip)
      if has_parameters?(params, %w(reference))
        if has_parameters?(params, %w(visits_since))
          if TrimUrl.exists?({ :reference => params[:reference] })

            api_set_response("OK", 200, "tr.im Statistics Returned.")

            trim_url = TrimUrl.first(:conditions => { :reference => params[:reference] }, :include => [ :shortening ])
            @api["reference"] = params[:reference]
            @api["trimpath"] = trim_url.shortening.surl
            @api["visits_since"] = params[:visits_since]

            conditions = ["trim_url_id = ? AND created_at > ?", trim_url.id, params[:visits_since].to_i.seconds.ago]
            if TrimClick.exists?({ :trim_url_id => trim_url.id })
              @api["visits"] = TrimClick.count(:id, :conditions => conditions) 
            else
              @api["visits"] = 0 end

          else api_set_error_response(412) end
        else api_set_error_response(446) end
      else api_set_error_response(411) end
    else api_set_error_response(425) end
    set_final_response
  end
end
