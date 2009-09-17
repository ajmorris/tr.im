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

class Account::UsernameController < ApplicationController
  before_filter :has_session_with_redirect?
  before_filter :ajax?

  def update
    if params[:user].blank? || params[:user][:login].blank?
      render :partial => "error", :locals => { :error_text => t(:username_missing, :scope => :errors) }

    elsif @user.login == params[:user][:login].downcase
      @user[:name] = params[:user][:name] unless params[:user][:name].blank?
      @user.save(false)
      render :update do |page|
        page.replace_html 'username_update', :partial => "done" end

    elsif User.exists?({ :login => params[:user][:login].downcase })
      render :partial => "error", :locals => { :error_text => t(:username_taken, :scope => :errors) }

    else
      @user[:name] = params[:user][:name] unless params[:user][:name].blank?
      @user[:login] = params[:user][:login].downcase
      @user.save(false) end
  end
end
