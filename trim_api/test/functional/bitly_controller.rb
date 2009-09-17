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

class BitlyControllerTest < ActionController::TestCase
  def setup
    @controller = One::BitlyController.new 
    @request  = ActionController::TestRequest.new 
    @response = ActionController::TestResponse.new
  end


  test "bitly shorten without long url" do
    assert_no_difference("TrimUrl.count") do
      get :shorten, bp
      assert_response :success
    end
    assert_equal "ERROR", JSON.parse(@response.body)["statusCode"]
  end

  test "bitly shorten" do
    assert_difference("TrimUrl.count", 1) do
      get :shorten, bp.merge!({ :longUrl => url_destinations(:google).url })
      assert_response :success
    end
    json = JSON.parse(@response.body)
    assert_equal "OK", json["statusCode"]
    assert_equal true, json["results"].has_key?(url_destinations(:google).url)
  end


  test "bitly expand without short url" do
    get :expand, bp
    assert_response :success
    assert_equal "ERROR", JSON.parse(@response.body)["statusCode"]
  end
  
  test "bitly expand" do
    get :expand, bp.merge!({ :shortUrl => url_shortenings(:google).surl })
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal "OK", json["statusCode"]
    assert_equal true, json["results"].has_key?(url_shortenings(:google).surl)
  end
end
