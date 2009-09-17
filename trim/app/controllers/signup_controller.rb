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

class SignupController < ApplicationController
  before_filter :ajax?, :only => [ :create ]
  before_filter :set_tlds, :only => [ :create ]

  def index
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Create an Account"
    @sb = "none"
    @tab = "none"
    @tagline = "#{word_website} Signup"
  end

  def create
    if params.has_key?("user") && has_parameters?(params[:user], %w(login password email))
      @user = User.new do |nu|
        nu[:website_id] = WEBSITE_CONFIG['website_id']
        nu[:origin_id] = WEBSITE_CONFIG['website_id']
        nu[:language_id] = @language.id
        nu[:name] = User::DEFAULT_NAME
        nu[:login] = params[:user][:login].downcase
        nu[:email] = params[:user][:email]
        nu[:country_id] = TrimCountry::INITIAL_DEFAULT
        nu[:last_ip] = @remote_ip
        nu[:source] = User::SOURCE_MANUAL
      end
      @user.set_password(params[:user][:password])
      @user.save
      if @user.errors.empty?

        send_signup_email(TrimEmail::SIGNUP_TRIM, { "to" => @user.email, "login" => @user.login })
        start_session(WEBSITE_CONFIG['website_id'], params[:user][:login].downcase, params[:user][:password])
        set_session_urls_as_user_urls
        set_trims_with_charts(true, TrimsList::MAX_URLS_IN_LIST)
        render :update do |page|
          page.redirect_to signup_done_path end

      else
        render :partial => "signup/rjs/failed" end
    else
      render :partial => "signup/rjs/incomplete" end
  end

  def done
    @pt = "#{WEBSITE_CONFIG['website_domain']} | Signup Completed"
    @sb = "none"
    @tab = "none"
    @tagline = "&nbsp;"
  end
  
  protected
  def send_signup_email(id, values)
    spawn do
      email = TrimEmail.find(id)
      email.deliver(values)
    end
  end

  def render_taken_loginid
    resets =  get_errors_reset
    render :update do |page|
      page << resets
      page.replace_html 'errors_signup', t(:signup_taken, :scope => :errors)
      page << "$('user_login').focus()"
      page << "$('user_login').setStyle({border: '1px solid #97391D'})"
    end
  end
  def render_taken_email
    resets =  get_errors_reset
    render :update do |page|
      page << resets
      page.replace_html 'errors_signup', t(:signup_email_used, :scope => :errors)
      page << "$('user_email').focus()"
      page << "$('user_email').setStyle({border: '1px solid #97391D'})"
    end
  end
  def render_missing_items
    resets =  get_errors_reset
    render :update do |page|
      page << resets
      page.replace_html 'errors_signup', t(:signup_missing_data, :scope => :errors)
      if (not params.has_key?[:user]) || params[:user][:email].blank?
        page << "$('user_email').focus()"
        page << "$('user_email').setStyle({border: '1px solid #97391D'})"
      end
      if (not params.has_key?[:user]) || params[:user][:password].blank?
        page << "$('user_password').focus()"
        page << "$('user_password').setStyle({border: '1px solid #97391D'})"
      end
      if (not params.has_key?[:user]) || params[:user][:login].blank?
        page << "$('user_login').focus()"
        page << "$('user_login').setStyle({border: '1px solid #97391D'})"
      end
    end
  end

  def render_model_errors(errors)
    resets =  get_errors_reset
    messages = String.new
    render :update do |page|
      page << resets
      if errors.on("login")
        page << "$('user_login').focus()"
        page << "$('user_login').setStyle({border: '1px solid #97391D'})"
        errors.on("login").each {|s| messages += s }
      end
      if errors.on("password")
        page << "$('user_password').focus()"
        page << "$('user_password').setStyle({border: '1px solid #97391D'})"
        errors.on("password").each {|s| messages += s }
      end
      if errors.on("email")
        page << "$('user_email').focus()"
        page << "$('user_email').setStyle({border: '1px solid #97391D'})"
        errors.on("email").each {|s| messages += s }
      end
      page.replace_html 'errors_signup', "#{messages} #{t(:again, :scope => :errors)}"
    end
  end

  def get_errors_reset
    tmps  = "$('user_login').setStyle({border: '1px solid #A5C1D1'}); "
    tmps += "$('user_password').setStyle({border: '1px solid #A5C1D1'}); "
    tmps += "$('user_email').setStyle({border: '1px solid #A5C1D1'});"
    return tmps
  end
end
