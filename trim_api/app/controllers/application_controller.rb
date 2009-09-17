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

class ApplicationController < ActionController::Base
  include ActionView::Helpers::DateHelper
  before_filter :set_ipaddress, :set_timezone
  before_filter :api_initialize, :api_user_agent, :set_api_methods, :set_api_method, :api_valid_format?

  protect_from_forgery :only => [ :create, :update, :delete ]
  filter_parameter_logging :password
  helper :all
  layout nil

  protected
  def set_final_response
    if api_http_reject?
      render :nothing => true, :status => "403"
    else
      render :json => api_set_response_json(params[:callback]) if params[:format] == "json" end
  end
  
  def get_timeago_inwords(dt)
    return {
      :en => "#{time_ago_in_words(dt)} ago"
    } if dt.to_i > 0
  end
end
