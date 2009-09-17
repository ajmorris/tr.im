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

require 'digest/sha2'

class User < ActiveRecord::Base
  before_validation :set_password?
  before_save :set_email

  belongs_to :website
  belongs_to :language

  has_many :logins, :class_name => "UserLogin"
  has_many :searches, :class_name => "AccountSearch", :include => [ :search ]

  has_many :oauths, :class_name => "NetworkOAuth", :order => "username", :through => :user_oauths
  has_many :user_oauths, :class_name => "UserOAuth"
  has_many :disqus, :class_name => "UserDisqus"

  MINIMUM_PASSWORD_LENGTH = 4
  DEFAULT_NAME = "UNKNOWN"
  DEFAULT_EMAIL = "UNKNOWN"

  SOURCE_API = "API"
  SOURCE_AUTO = "AUTO"
  SOURCE_MANUAL = "MANUAL"

  validates_uniqueness_of :login, :message => "you entered is already taken."
  validates_uniqueness_of :email, :message => "you entered is already in use with another account."
  validates_length_of :login, :in => 2..48, :message => "must be a minimum of 2 characters."

  validates_presence_of :salt
  validates_presence_of :password

  validates_format_of :login, :with => /^\w+$/i, :message => "can only contain letters and numbers."
  validates_format_of :email, :with => /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}$/i, :message => "is not valid"

  def set_password(password)
    self.salt = User.get_salt
    self.password = User.get_hash(self.salt, password)
  end
  def valid_password?(password)
    self.password == User.get_hash(self.salt, password)
  end
  
  def owns_this_oauth?(oauth_id)
    self.oauths.each {|auth| return true if auth.id == oauth_id }
    return false
  end
  
  def oauths_at_website(website_id)
    oauths = []
    self.oauths.each {|auth| oauths << auth if auth.website_id == website_id }
    return oauths
  end
  def has_oauth_at_website?(website_id)
    self.oauths.each {|auth| return true if auth.website_id == website_id }
    return false
  end
  def has_oauths_at_website?(website_id)
    found = 0
    self.oauths.each do |auths|
      found += 1 if self.oauths.website_id == website_id
      return true if found >= 2 
    end if self.oauths.size >= 2
    return false
  end

  protected
  def set_email
    self.email = self.email.downcase
  end
  def set_password?
    self.set_password(self.password) if self.salt == nil
  end

  def User.get_salt
    salt = String.new
    64.times { salt << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
    return salt
  end
  def User.get_hash(salt, password)
    Digest::SHA512.hexdigest("#{password}:#{salt}")
  end
end
