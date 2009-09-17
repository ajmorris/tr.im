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

require 'test_helper'

class StatisticsControllerTest < ActionController::TestCase
  def setup
    @controller = One::StatisticsController.new 
    @request  = ActionController::TestRequest.new 
    @response = ActionController::TestResponse.new
  end


  test "url visits" do
    get :url_visits, bp.merge!({ :reference => trim_urls(:google).reference })
    assert_response :success
    assert_equal 0, JSON.parse(@response.body)["total_visits"]
  end
  
  
  test "url activity" do
    get :url_activity, bp.merge!({ :reference => trim_urls(:google).reference, :visits_since => "3600" })
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal "3600", json["visits_since"]
    assert_equal trim_urls(:google).reference, JSON.parse(@response.body)["reference"]
  end
end

