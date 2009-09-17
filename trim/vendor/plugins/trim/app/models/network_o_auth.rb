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

class NetworkOAuth < ActiveRecord::Base
  DEFAULT_USERNAME = "UNKNOWN"
  STATUS_PENDING = "PENDING"
  STATUS_DONE = "DONE"

  belongs_to :network
  has_many :keys, :class_name => "AccountKey", :foreign_key => "oauth_id"
  has_many :users, :class_name => "User", :through => :user_oauths
  has_many :user_oauths, :class_name => "UserOAuth", :foreign_key => "oauth_id"
  has_many :session_oauths, :class_name => "SessionOAuth", :foreign_key => "oauth_id"
  has_many :trim_claimants, :class_name => "TrimClaimant", :foreign_key => "oauth_id"

  def owned_by_user_id?(user_id)
    self.users.each {|u| return true if u.id == user_id }
    return false
  end
  def has_trim_claimant_for_user_id?(user_id)
    self.trim_claimants.each {|tc| return true if tc.user_id == user_id }
    return false
  end
end
