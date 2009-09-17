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

class UrlControllerTest < ActionController::TestCase
  def setup
    @controller = One::UrlController.new 
    @request  = ActionController::TestRequest.new 
    @response = ActionController::TestResponse.new
  end


  test "trim url" do
    assert_difference("TrimUrl.count", 1) do
      get :trim_url, bp.merge!({ :url => "http://yahoo.com" })
      assert_response :success
    end
    json = JSON.parse(@response.body)
    assert_equal "200", json["status"]["code"]
    assert_equal "yahoo.com", json["domain"]
    assert_equal "http://yahoo.com/", json["destination"]
  end


  test "trim simple" do
    assert_difference("TrimUrl.count", 1) do
      get :trim_url, bp.merge!({ :url => "http://yahoo.com" })
      assert_response :success
    end
  end
  
  
  test "trim reference without trimpath" do
    get :trim_reference, bp_auth
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal "413", json["status"]["code"]
  end
  
  test "trim reference xml" do
    get :trim_reference, bp.merge!({ :format => "xml" })
    assert_response :success
  end

  test "trim reference" do
    get :trim_reference, bp_auth.merge!({ :trimpath => url_shortenings(:google).surl })
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal "200", json["status"]["code"]
    assert_equal trim_urls(:google).reference, json["reference"]
  end
  
  
  test "trim destination xml" do
    get :trim_reference, bp.merge!({ :format => "xml", :trimpath => url_shortenings(:google).surl })
    assert_response :success
  end
  
  test "trim destination" do
    get :trim_destination, bp_auth.merge!({ :trimpath => url_shortenings(:google).surl })
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal "200", json["status"]["code"]
    assert_equal url_destinations(:google).url, json["destination"]
  end
  
  
  test "trim claim already claimed" do
    assert_no_difference("TrimUserUrl.count") do
      get :trim_claim, bp_auth.merge!({ :reference => trim_urls(:google).reference })
      assert_response :success
    end
    json = JSON.parse(@response.body)
    assert_equal "415", json["status"]["code"]
  end
  
  test "trim claim xml" do
    assert_difference("TrimUserUrl.count", 1) do
      get :trim_claim, bp_auth.merge!({ :format => "xml", :reference => trim_urls(:unclaimed).reference })
      assert_response :success
    end
  end
  
  test "trim claim" do
    assert_difference("TrimUserUrl.count", 1) do
      get :trim_claim, bp_auth.merge!({ :reference => trim_urls(:unclaimed).reference })
      assert_response :success
    end
    json = JSON.parse(@response.body)
    assert_equal "200", json["status"]["code"]
  end
end
