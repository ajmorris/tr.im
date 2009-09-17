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

class Account::EmailController < ApplicationController
  before_filter :has_session_with_redirect?
  before_filter :ajax?, :only => [ :update ]

  def show
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Account | Email Address"
    @sb = "email"
    @tab = "account"
    @tagline = "#{WEBSITE_CONFIG['website_domain']} Email Address"
  end
  
  def update
    if params[:email][:new].blank? || params[:email][:confirm].blank?
      render :partial => "error", :locals => { :error_text => t(:email_missing, :scope => :errors) }

    elsif params[:email][:new].downcase != params[:email][:confirm].downcase
      render :partial => "error", :locals => { :error_text => t(:email_notmatched, :scope => :errors) }
      
    elsif user_email_exists?(WEBSITE_CONFIG['website_id'], params[:email][:confirm])
      render :partial => "error", :locals => { :error_text => t(:email_inuse, :scope => :errors) }

    else
      @user[:email] = params[:email][:new].downcase
      @user.save(false) end
  end
end
