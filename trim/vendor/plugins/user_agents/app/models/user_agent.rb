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

class UserAgent < ActiveRecord::Base
  set_table_name "user_agents"
  
  belongs_to :platform, :class_name => "UserPlatform", :foreign_key => "platform_id"
  belongs_to :browser,  :class_name => "UserBrowser",  :foreign_key => "browser_id"

  UNKNOWN = 1
  
  IPHONE_WIDTH = 320
  IPHONE_HEIGHT = 480

  def is_iphone?
    self.details.include?("iPhone") || self.details.include?("iPod")
  end
  def is_nambu?
    (self.details == "CFNetwork/221.5") || (self.details.include?("Nambu") && self.details.include?("CFNetwork"))
  end

  def is_bot?
    self.browser.is_bot?
  end
  def is_browser?
    self.browser.is_browser?
  end
end
