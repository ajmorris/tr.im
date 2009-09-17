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

class Account::PasswordController < ApplicationController
  before_filter :has_session_with_redirect?
  before_filter :ajax?

  def update
    if params[:data][:old].blank?
      render :partial => "error_current", :locals => { :error_text => t(:password_needauth, :scope => :errors) }

    elsif @user.password != params[:data][:old]
      render :partial => "error_current", :locals => { :error_text => t(:password_badauth, :scope => :errors) }

    else
      if not params[:data][:new].blank? && params[:data][:new].length > User::MINIMUM_PASSWORD_LENGTH
        if params[:data][:new] == params[:data][:new_confirm]

          @user[:password] = params[:data][:new]
          @user.save(false)

        else
          render :partial => "error_new", :locals => { :error_text => t(:password_nomatch, :scope => :errors) } end
      else
        render :partial => "error_new", :locals => { :error_text => t(:password_nomatch, :scope => :errors) } end        
    end
  end
end
