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

class UserAgentFilter < ActiveRecord::Base
  belongs_to :platform, :class_name => "UserPlatform", :foreign_key => "platform_id"
  belongs_to :browser, :class_name => "UserBrowser", :foreign_key => "browser_id"
  has_many :terms, :class_name => "UserAgentTerm", :foreign_key => "filter_id", :dependent => :destroy
  
  def terms_attributes=(terms_attributes)
    terms_attributes.each do |attributes|
      terms.create(attributes) unless self.new_record?
    end
  end
  
  def has_terms?
    (not self.terms.empty?)
  end
  def qs
    i, tmps = 0, String.new
    self.terms.each do |t|
      tmps += " AND " if i > 0
      tmps += " details LIKE '%#{t.term}%'"
      i += 1
    end
    return tmps
  end
end
